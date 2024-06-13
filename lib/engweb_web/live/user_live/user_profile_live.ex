defmodule EngwebWeb.UserLive.UserProfileLive do
  use EngwebWeb, :live_view

  alias Engweb.Accounts
  alias Engweb.Roads

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, :unauthorized}

      user ->
        roads = Roads.list_user_roads(user.id)
        comments = Roads.list_user_comments(user.id)

        {:ok, assign(socket, user: user, active_tab: :overview, roads: roads, comments: comments)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    tab = params["tab"] || "overview"
    {:noreply, assign(socket, :active_tab, String.to_atom(tab))}
  end

  def profile_url(socket, tab) do
    "/users/profile?tab=#{tab}"
  end
end
