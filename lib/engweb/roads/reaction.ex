defmodule Engweb.Roads.Reaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roads_reactions" do
    field :reaction_type, :string
    field :comment_id, :id
    field :user_id, :id


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:reaction_type, :comment_id, :user_id])
    |> validate_required([:reaction_type, :comment_id, :user_id])
    |> validate_inclusion(:reaction_type, ["like", "dislike"])
    |> unique_constraint([:comment_id, :user_id], name: :unique_reaction_per_user_per_comment)
  end
end
