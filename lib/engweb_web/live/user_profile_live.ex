defmodule EngwebWeb.UserProfileLive do
  use EngwebWeb, :live_view

  alias Engweb.Accounts

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Accounts.get_user_by_session_token(user_token) do
      nil ->
        {:error, :unauthorized}

      user ->
        {:ok, assign(socket, :user, user)}
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
