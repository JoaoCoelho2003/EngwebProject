defmodule EngwebWeb.RoadLive.Index do
  use EngwebWeb, :live_view

  alias Engweb.Roads
  alias Engweb.Roads.Road

  @impl true
  def mount(_params, _session, socket) do
    roads = Roads.list_roads() |> Enum.sort_by(& &1.num)
    {:ok, stream(socket, :roads, roads)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Road")
    |> assign(:road, Roads.get_road!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Road")
    |> assign(:road, %Road{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Roads")
    |> assign(:road, nil)
  end

  @impl true
  def handle_info({EngwebWeb.RoadLive.FormComponent, {:saved, road}}, socket) do
    {:noreply, stream_insert(socket, :roads, road)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    road = Roads.get_road!(id)
    {:ok, _} = Roads.delete_road(road)

    {:noreply, stream_delete(socket, :roads, road)}
  end
end
