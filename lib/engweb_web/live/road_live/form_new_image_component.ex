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
        multipart
      >
        <%= if @action == :image do %>
          <div class="flex flex-col">
            <p class="mb-2">Image</p>
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
        <% else %>
          <div class="flex flex-col">
            <p class="mb-2">Current Image</p>
            <%= for index <- 0..(@uploads.current_image.max_entries - 1) do %>
              <p class="mb-2">Current Image <%= index + 1 %></p>
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
        <:actions>
          <.button phx-disable-with="Saving...">Save Image</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(%{action: :new_image} = assigns, socket) do
    {:ok,
      socket
        |> assign(assigns)
        |> assign(:form, %Roads.Road{})
        |> allow_upload(:image, accept: ~w(.png .jpg .jpeg), max_entries: 1)
        |> assign(:descriptions, %{})
        |> assign(:uploaded_images, [])
    }
  end

  def update(%{action: :current_image} = assigns, socket) do
    {:ok,
      socket
        |> assign(assigns)
        |> assign(:form, %Roads.Road{})
        |> allow_upload(:current_image, accept: ~w(.png .jpg .jpeg), max_entries: 1)
        |> assign(:uploaded_current_images, [])
    }
  end

  def handle_event("validate-description", %{"description_0" => description}, socket) do
    ref = Enum.at(socket.assigns.uploads.image.entries, 0).ref
    descriptions = Map.put(socket.assigns.descriptions, ref, description)
    {:noreply, assign(socket, :descriptions, descriptions)}
  end

  def handle_event("save", _, socket) do
    save_image(socket, socket.assigns.action)
  end

  defp save_image(socket, :new_image) do
    {:noreply, socket} = consume_uploaded_images(socket, :new_image)

    create_images(socket, socket.assigns.road_id, :new_image)

    {:noreply,
    socket
      |> put_flash(:info, "Image created successfully")
      |> push_patch(to: socket.assigns.patch)}
  end

  defp save_image(socket, :new_current_image) do
    {:noreply, socket} = consume_uploaded_images(socket, :new_current_image)

    create_current_images(socket, socket.assigns.road_id, :new_current_image)

    {:noreply,
    socket
      |> put_flash(:info, "Current Image created successfully")
      |> push_patch(to: socket.assigns.patch)}
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
end
