defmodule Engweb.Repo.Migrations.CreateRoads do
  use Ecto.Migration

  def change do
    create table(:roads) do
      add :name, :string
      add :description, :text
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end
  end
end
