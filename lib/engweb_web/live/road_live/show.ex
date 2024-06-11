defmodule EngwebWeb.RoadLive.Show do
  use EngwebWeb, :live_view

  alias Engweb.Roads
  alias Engweb.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    road = Roads.get_road!(id) |> Repo.preload([:images, :current_image, :houses])
    images = road.images
    current_image = road.current_image
    houses = road.houses

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:road, road)
     |> assign(:images, images)
     |> assign(:current_image, current_image)
     |> assign(:houses, houses)}
  end

  defp page_title(:show), do: "Show Road"
  defp page_title(:edit), do: "Edit Road"
  defp page_title(:delete), do: "Delete Road"
end
