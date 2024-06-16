defmodule EngwebWeb.RoadLive.FormNewImageComponent do
  use EngwebWeb, :live_component

  alias Engweb.Roads
  alias EngwebWeb.RoadLive.{CurrentImageUploader, ImageUploader}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>
      <.simple_form
        for={@form}
        id="image-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate"
        multipart
      >
        <%= if @action == :new_image do %>
          <div class="flex flex-col">
            <%= for index <- 0..(@uploads.image.max_entries - 1) do %>
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
        <% else %>
          <div class="flex flex-col">
            <p class="mb-2">Current Image</p>
            <%= for index <- 0..(@uploads.current_image.max_entries - 1) do %>
              <.live_component
                module={CurrentImageUploader}
                id={"current_uploader_#{index + 1}"}
                uploads={@uploads}
                target={@myself}
                index={index}
                class={
                  if length(@uploads.current_image.entries) < (index + 1) do
                    ""
                  else
                    "hidden"
                  end
                }
              />
            <% end %>
          </div>
        <% end %>
        <div class="flex flex-col gap-y-2">
          <%= for {_field, message} <- @error do %>
            <p class="text-red-500"><%= message %></p>
          <% end %>
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Image</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{action: action} = assigns, socket) do
    changeset = Roads.change_road(assigns.road)
    case action do
      :new_image ->
        {:ok,
          socket
            |> assign(assigns)
            |> assign(:form, changeset)
            |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 1)
            |> assign(:descriptions, %{})
            |> assign(:uploaded_images, [])
            |> assign(:error, %{})
        }
      :new_current_image ->
        {:ok,
          socket
            |> assign(assigns)
            |> assign(:form, changeset)
            |> allow_upload(:current_image, accept: ~w(.png .jpg .jpeg), max_entries: 1)
            |> assign(:uploaded_current_images, [])
            |> assign(:error, %{})
        }
    end

  end

  @impl true
  def handle_event("validate-description", %{"description_0" => description}, socket) do
    ref = Enum.at(socket.assigns.uploads.image.entries, 0).ref
    descriptions = Map.put(socket.assigns.descriptions, ref, description)
    {:noreply, assign(socket, :descriptions, descriptions)}
  end

  def handle_event("save", _, socket) do
    if (socket.assigns.current_user.id != socket.assigns.road.user_id) and (socket.assigns.current_user.role != "admin") do
      {:noreply, socket |> put_flash(:error, "You are not allowed to create images for this road")}
    else
      save_image(socket, socket.assigns.action)
    end
  end

  def handle_event("validate", %{"_target" => _image}, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-image", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("cancel-current-image", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :current_image, ref)}
  end

  defp save_image(socket, :new_image) do
    case validate_image(socket, :new_image) do
      {:ok, socket} ->
        {:noreply, socket} = consume_uploaded_images(socket, :new_image)

        create_images(socket, socket.assigns.road.id, :new_image)

        {:noreply,
        socket
          |> put_flash(:info, "Image created successfully")
          |> push_patch(to: socket.assigns.patch)}

      {:error, socket} -> {:noreply, socket}
    end
  end

  defp save_image(socket, :new_current_image) do
    case validate_image(socket, :new_current_image) do
      {:ok, socket} ->
        {:noreply, socket} = consume_uploaded_images(socket, :new_current_image)

        create_current_images(socket, socket.assigns.road.id, :new_current_image)

        {:noreply,
        socket
          |> put_flash(:info, "Current Image created successfully")
          |> push_patch(to: socket.assigns.patch)}

        {:error, socket} -> {:noreply, socket}
      end
    end

  defp consume_uploaded_images(socket, :new_image) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        dest = Path.join([:code.priv_dir(:engweb), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, {~p"/uploads/#{Path.basename(dest)}", socket.assigns.descriptions[entry.ref]}}
      end)

    {:noreply, update(socket, :uploaded_images, &(&1 ++ uploaded_files))}
  end

  defp consume_uploaded_images(socket, :new_current_image) do
    uploaded_files =
      consume_uploaded_entries(socket, :current_image, fn %{path: path}, _entry ->
        dest = Path.join([:code.priv_dir(:engweb), "static", "uploads", Path.basename(path)])
        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)
    {:noreply, update(socket, :uploaded_current_images, &(&1 ++ uploaded_files))}
  end

  defp create_images(socket, road_id, :new_image) do
    Enum.each(socket.assigns.uploaded_images, fn path ->
      Roads.create_image(%{road_id: road_id, image: elem(path,0), legenda: elem(path,1)})
    end)
  end

  defp create_current_images(socket, road_id, :new_current_image) do
    Enum.each(socket.assigns.uploaded_current_images, fn path ->
      Roads.create_current_images(%{road_id: road_id, image: path})
    end)
  end

  defp validate_image(socket, :new_image) do
    socket = validate_descriptions(socket)

    errors = socket.assigns.error

    errors =
      if length(socket.assigns.uploads.image.entries) == 0 do
        Map.put(errors, "min_image", "You must provide one image")
      else
        Map.delete(errors, "min_image")
      end

    errors =
      if length(socket.assigns.uploads.image.entries) > socket.assigns.uploads.image.max_entries do
        Map.put(errors, "max_image", "You can only upload up to #{socket.assigns.uploads.image.max_entries} images")
      else
        Map.delete(errors, "max_image")
      end

    if map_size(errors) > 0 do
      {:error, socket |> assign(:error, errors)}
    else
      {:ok, socket}
    end
  end

  defp validate_image(socket, :new_current_image) do
    errors = socket.assigns.error

    errors =
      if length(socket.assigns.uploads.current_image.entries) == 0 do
        Map.put(errors, "min_current_image", "You must provide one image")
      else
        Map.delete(errors, "min_current_image")
      end

    errors =
      if length(socket.assigns.uploads.current_image.entries) > socket.assigns.uploads.current_image.max_entries do
        Map.put(errors, "max_current_image", "You can only upload up to #{socket.assigns.uploads.current_image.max_entries} images")
      else
        Map.delete(errors, "max_current_image")
      end

    if map_size(errors) > 0 do
      {:error, socket |> assign(:error, errors)}
    else
      {:ok, socket}
    end
  end

  defp validate_descriptions(socket) do
    errors =
      if length(socket.assigns.uploads.image.entries) != map_size(socket.assigns.descriptions) do
        Map.put(socket.assigns.error, "description", "You must provide a description for each image")
      else
        Map.delete(socket.assigns.error, "description")
      end

    assign(socket, :error, errors)
  end
end
