defmodule EngwebWeb.RoadLive.Index do
  use EngwebWeb, :live_view
  alias Engweb.Roads
  alias Engweb.Roads.Road

  @impl true
  def mount(_params, _session, socket) do
    roads = list_roads()

    {:ok, stream(socket, :roads, roads)}
  end

  defp load_road_data(road) do
    images =
      road
        |> Engweb.Repo.preload(:images)
        |> Map.get(:images)

    current_images =
      road
        |> Engweb.Repo.preload(:current_images)
        |> Map.get(:current_images)

    %{road | images: images, current_images: current_images}
  end

  @impl true
  def handle_params(params, _url, socket) do
    roads = list_roads()
    {:noreply, apply_action(stream(socket, :roads, roads, reset: true), socket.assigns.live_action, params)}
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

  defp apply_action(socket, :houses, params) do
    road = Roads.get_road!(params["id"])
    socket
    |> assign(:page_title, "Houses")
    |> assign(:road, road)
    |> assign(:images, [])
    |> assign(:current_images, [])
  end

  @impl true
  def handle_info({EngwebWeb.RoadLive.FormComponent, {:saved, _road}}, socket) do
    {:noreply, socket}
  end

  def handle_info({:clear_flash, key}, socket) do
    socket = clear_flash(socket, key)
    roads = list_roads()
    {:noreply, stream(socket, :roads, roads, reset: true)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    roads = list_roads(query)
    {:noreply, stream(socket, :roads, roads, reset: true)}
  end

  def handle_event("phx:clear-flash", %{"key" => _key}, socket) do
    roads = list_roads()
    {:noreply, stream(socket, :roads, roads, reset: true)}
  end

  defp list_roads(query \\ "") do
    if String.trim(query) != "" do
      Roads.filter_roads_by_name(query)
    else
      Roads.list_roads()
    end
    |> Enum.map(&load_road_data/1)
    |> Enum.sort_by(& &1.id)
  end
end
