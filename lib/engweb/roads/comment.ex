defmodule Engweb.Roads.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roads_comments" do
    field :comment, :string
    field :road_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:comment])
    |> validate_required([:comment])
  end
end
