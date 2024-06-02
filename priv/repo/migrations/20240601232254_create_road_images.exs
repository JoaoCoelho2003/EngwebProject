defmodule Engweb.Repo.Migrations.CreateRoadImages do
  use Ecto.Migration

  def change do
    create table(:road_images) do
      add :image, :string
      add :legenda, :string
      add :road_id, references(:roads, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:road_images, [:road_id])
  end
end
