defmodule EngwebWeb.RoadLive.Show do
  use EngwebWeb, :live_view

  alias Engweb.Roads

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(unsigned_params, _, socket) do
    id = unsigned_params["id"]
    road = Roads.get_road!(id)
    images = Roads.list_images_by_road(id)
    current_images = Roads.list_current_images_by_road(id)

    socket =
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:road, road)
     |> assign(:images, images)
     |> assign(:current_images, current_images)
     |> assign(:max_image_uploads, Roads.max_image_uploads())
     |> assign(:max_current_image_uploads, Roads.max_current_image_uploads())

    case socket.assigns.live_action do
      :delete_image ->
        image_id = unsigned_params["image_id"]
        {:noreply, socket |> assign(:image, image_id)}
      :delete_current_image ->
        current_image_id = unsigned_params["current_image_id"]
        {:noreply, socket |> assign(:current_image, current_image_id)}
      _ ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Road"
  defp page_title(:edit), do: "Edit Road"
  defp page_title(:delete), do: "Delete Road"
  defp page_title(:delete_image), do: "Delete Image"
  defp page_title(:delete_current_image), do: "Delete Current Image"
  defp page_title(:new_image), do: "New Image"
  defp page_title(:new_current_image), do: "New Current Image"

end
