defmodule Engweb.Roads.Comment do
  use Ecto.Schema
  alias Engweb.Repo
  import Ecto.Changeset

  schema "roads_comments" do
    field :comment, :string
    field :likes, :integer
    field :dislikes, :integer
    field :road_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:comment, :likes, :dislikes, :road_id, :user_id])
    |> validate_required([:comment, :likes, :dislikes, :road_id, :user_id])
  end
end
