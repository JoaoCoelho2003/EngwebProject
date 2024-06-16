defmodule EngwebWeb.UserLive.UserProfileLive do
  use EngwebWeb, :live_view

  alias Engweb.Accounts
  alias Engweb.Roads
  alias Engweb.Repo

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, :unauthorized}

      user ->
        roads = list_user_roads_with_images(user.id)
        comments = Roads.list_user_comments_inserted(user.id)

        {:ok, assign(socket, user: user, active_tab: :roads, roads: roads, comments: comments)}
    end
  end

  defp list_user_roads_with_images(user_id) do
    Roads.list_user_roads_inserted(user_id)
    |> Repo.preload([:images, :current_images])
    |> Enum.map(&load_road_data/1)
  end

  defp load_road_data(road) do
    %{road | images: road.images, current_images: road.current_images}
  end

  @impl true
  def handle_params(params, _url, socket) do
    tab = params["tab"] || "roads"
    {:noreply, assign(socket, :active_tab, String.to_atom(tab))}
  end

  @impl true
  def handle_event("navigate_to_road", %{"id" => id}, socket) do
    road_url = "/roads/#{id}"
    {:noreply, redirect(socket, to: road_url)}
  end

  def profile_url(user_id, tab) do
    "/users/#{user_id}/profile?tab=#{tab}"
  end
end
