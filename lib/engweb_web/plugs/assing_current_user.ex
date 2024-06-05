defmodule EngwebWeb.Plugs.AssignCurrentUser do
  import Plug.Conn
  alias Engweb.Accounts

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    current_user = user_id && Accounts.get_user!(user_id)
    assign(conn, :current_user, current_user)
  end
end
