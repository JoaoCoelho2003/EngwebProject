defmodule Engweb.Repo.Migrations.CreateRoadsComments do
  use Ecto.Migration

  def change do
    create table(:roads_comments) do
      add :comment, :text
      add :road_id, references(:roads, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:roads_comments, [:road_id])
    create index(:roads_comments, [:user_id])
  end
end
