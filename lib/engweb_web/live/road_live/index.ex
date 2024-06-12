defmodule EngwebWeb.RoadLive.Index do
  use EngwebWeb, :live_view

  alias Engweb.Roads
  alias Engweb.Roads.Road

  @impl true
  def mount(_params, _session, socket) do
    roads = Roads.list_roads()
             |> Enum.map(&load_road_data/1)
             |> Enum.sort_by(& &1.id)

    {:ok, stream(socket, :roads, roads)}
  end

  defp load_road_data(road) do
    images = road
             |> Engweb.Repo.preload(:images)
             |> Map.get(:images)

    current_images = road
                    |> Engweb.Repo.preload(:current_images)
                    |> Map.get(:current_images)

    %{road | images: images, current_images: current_images}
  end



  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Road")
    |> assign(:road, %Road{})
    |> assign(:images, [])
    |> assign(:current_images, [])
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Roads")
    |> assign(:road, nil)
    |> assign(:images, [])
    |> assign(:current_images, [])
  end
end
