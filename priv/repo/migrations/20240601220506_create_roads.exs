defmodule Engweb.Repo.Migrations.CreateRoads do
  use Ecto.Migration

  def change do
    create table(:roads) do
      add :num, :integer
      add :name, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
