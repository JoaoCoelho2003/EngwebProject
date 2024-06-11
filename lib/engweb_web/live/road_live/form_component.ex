defmodule EngwebWeb.RoadLive.FormComponent do
  use EngwebWeb, :live_component

  alias Engweb.Roads
  alias EngwebWeb.RoadLive.{CurrentImageUploader, ImageUploader}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage road records in your database.</:subtitle>
      </.header>
      <%= if @action == :delete do %>
        <div class="flex justify-end">
          <.simple_form
            for={@form}
            id="road-form"
            phx-target={@myself}
            phx-submit="delete"
          >
          <:actions>
            <.button phx-disable-with="Deleting..." class="bg bg-red-600 hover:bg-red-700">Delete Road</.button>
          </:actions>
      </.simple_form>
      </div>
      <% else %>
        <.simple_form
          for={@form}
          id="road-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
          multipart
        >
          <.input field={@form[:num]} type="number" label="Num" />
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <div class="flex flex-col">
            <p class="mb-2">Images</p>
            <%= for index <- 0..(@uploads.image.max_entries - 1) do %>
              <p class="mb-2">Image <%= index + 1 %></p>
              <.live_component
                module={ImageUploader}
                id={"uploader_#{index + 1}"}
                uploads={@uploads}
                target={@myself}
                index={index}
                description={@descriptions[index] || ""}
                class={
                  if length(@uploads.image.entries) < (index + 1) do
                    ""
                  else
                    "hidden"
                  end
                }
              />
            <% end %>
          </div>
          <div>
            <p class="mb-2">Current Images</p>
            <.live_component module={CurrentImageUploader} id="uploader" uploads={@uploads} target={@myself} />
            </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Road</.button>
          </:actions>
      </.simple_form>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{road: road} = assigns, socket) do
    changeset = Roads.change_road(road)
    {:ok,
     socket
     |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 2)
     |> allow_upload(:current_image, accept: ~w(.png .jpg .jpeg), max_entries: 2)
     |> assign(:descriptions, %{})
     |> assign(:uploaded_images, [])
     |> assign(:uploaded_current_images, [])
     |> assign(assigns)
     |> assign_form(changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"road" => road_params}, socket) do
    changeset =
      socket.assigns.road
      |> Roads.change_road(road_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("validate-description", %{"description_0" => description}, socket) do
    ref = Enum.at(socket.assigns.uploads.image.entries, 0).ref
    descriptions = Map.put(socket.assigns.descriptions, ref, description)
    {:noreply, assign(socket, :descriptions, descriptions)}
  end

  def handle_event("validate-description", %{"description_1" => description}, socket) do
    ref = Enum.at(socket.assigns.uploads.image.entries, 1).ref
    descriptions = Map.put(socket.assigns.descriptions, ref, description)
    {:noreply, assign(socket, :descriptions, descriptions)}
  end

  def handle_event("save", %{"road" => road_params}, socket) do
    save_road(socket, socket.assigns.action, road_params)
  end

  def handle_event("delete", _params, socket) do
    delete_road(socket)
  end

  def handle_event("cancel-image", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("cancel-current-image", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :current_image, ref)}
  end

  defp save_road(socket, :edit, road_params) do
    if socket.assigns.road.user_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "You are not allowed to edit this road")}
    else
      case Roads.update_road(socket.assigns.road, road_params) do
        {:ok, road} ->
          notify_parent({:saved, road})

          {:noreply,
          socket
          |> put_flash(:info, "Road updated successfully")
          |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp save_road(socket, :new, road_params) do
    id = socket.assigns.current_user.id
    if id == nil do
      {:noreply, socket |> put_flash(:error, "You must be logged in to create a road")}
    else
      case Map.put(road_params, "user_id", id) |> Roads.create_road() do
        {:ok, road} ->
          # join images with descriptions and create_images

          {:noreply, socket} = consume_uploaded_images(socket, :image)

          {:noreply, socket} = consume_uploaded_images(socket, :current_image)

          create_images(socket, road, :image)

          create_current_images(socket, road, :current_image)

          notify_parent({:saved, road})

          {:noreply,
          socket
          |> put_flash(:info, "Road created successfully")
          |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp delete_road(socket) do
    if socket.assigns.road.user_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "You are not allowed to delete this road")}
    else
      case Roads.delete_road(socket.assigns.road) do
        {:ok, _} ->
          notify_parent({:deleted, socket.assigns.road})

          {:noreply,
          socket
          |> put_flash(:info, "Road deleted successfully")
          |> redirect(to: socket.assigns.patch)}

        {:error, _} ->
          {:noreply, socket |> put_flash(:error, "Error deleting road")}
      end
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp consume_uploaded_images(socket, :image) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        dest = Path.join([:code.priv_dir(:engweb), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, {~p"/uploads/#{Path.basename(dest)}", socket.assigns.descriptions[entry.ref]}}
      end)

    updated_socket = socket
      |> update(:uploaded_images, &(&1 ++ uploaded_files))

    {:noreply, updated_socket}
  end

  defp consume_uploaded_images(socket, :current_image) do
    uploaded_files =
      consume_uploaded_entries(socket, :current_image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:engweb), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
    {:noreply, update(socket, :uploaded_current_images, &(&1 ++ uploaded_files))}
  end

  defp create_images(socket, road, :image) do
    Enum.each(socket.assigns.uploaded_images, fn path ->
      Roads.create_image(%{road_id: road.id, image: elem(path,0), legenda: elem(path,1)})
    end)
  end

  defp create_current_images(socket, road, :current_image) do
    Enum.each(socket.assigns.uploaded_current_images, fn path ->
      Roads.create_current_images(%{road_id: road.id, image: path})
    end)
  end
end
