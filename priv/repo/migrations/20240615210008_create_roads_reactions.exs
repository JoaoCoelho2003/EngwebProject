defmodule Engweb.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:roads_reactions) do
      add :reaction_type, :string, null: false
      add :comment_id, references(:roads_comments, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:roads_reactions, [:comment_id, :user_id], name: :unique_reaction_per_user_per_comment)
  end
end
