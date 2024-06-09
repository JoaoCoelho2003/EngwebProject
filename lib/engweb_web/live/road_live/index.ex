defmodule EngwebWeb.RoadLive.Index do
  use EngwebWeb, :live_view
  alias Engweb.Roads
  alias Engweb.Roads.Road

  @impl true
  def mount(_params, _session, socket) do
    roads = Roads.list_roads()
             |> Enum.map(&load_road_data/1)
             |> Enum.sort_by(& &1.num)

    {:ok, stream(socket, :roads, roads)}
  end

  defp load_road_data(road) do
    images = road
             |> Engweb.Repo.preload(:images)
             |> Map.get(:images)

    current_image = road
                    |> Engweb.Repo.preload(:current_image)
                    |> Map.get(:current_image)

    %{road | images: images, current_image: current_image}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    road = Roads.get_road!(id) |> load_road_data()

    socket
    |> assign(:page_title, "Edit Road")
    |> assign(:road, road)
    |> assign(:images, road.images)
    |> assign(:current_image, road.current_image)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Road")
    |> assign(:road, %Road{})
    |> assign(:images, [])
    |> assign(:current_image, [])
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Roads")
    |> assign(:road, nil)
    |> assign(:images, [])
    |> assign(:current_image, [])
  end

  @impl true
  def handle_info({EngwebWeb.RoadLive.FormComponent, {:saved, road}}, socket) do
    road = road |> load_road_data()
    {:noreply, stream_insert(socket, :roads, road)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    road = Roads.get_road!(id)
    {:ok, _} = Roads.delete_road(road)

    {:noreply, stream_delete(socket, :roads, road)}
  end

  def handle_event("delete_image", %{"id" => id}, socket) do
    image = Roads.get_image!(id)
    {:ok, _} = Roads.delete_image(image)

    {:noreply,
      socket
      |> update(:images, fn images -> Enum.reject(images, &(&1.id == id)) end)
    }
  end

  def handle_event("search", %{"query" => query}, socket) do
    roads =
      if String.trim(query) != "" do
        Roads.filter_roads_by_name(query)
      else
        Roads.list_roads()
      end
      |> Enum.map(&load_road_data/1)
      |> Enum.sort_by(& &1.num)


    {:noreply, assign(socket, :roads, roads)}
  end

end
