defmodule Engweb.Repo.Migrations.CreateRoadsCurrentimages do
  use Ecto.Migration

  def change do
    create table(:roads_currentimages) do
      add :image, :string
      add :road_id, references(:roads, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:roads_currentimages, [:road_id])
  end
end
