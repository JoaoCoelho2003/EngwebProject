defmodule Engweb.Repo do
  use Ecto.Repo,
    otp_app: :engweb,
    adapter: Ecto.Adapters.Postgres
end
