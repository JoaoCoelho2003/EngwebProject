defmodule Engweb.Repo.Migrations.CreateRoadHouses do
  use Ecto.Migration

  def change do
    create table(:road_houses) do
      add :num, :string
      add :enfiteuta, :string
      add :foro, :string
      add :description, :text
      add :road_id, references(:roads, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:road_houses, [:road_id])
  end
end
