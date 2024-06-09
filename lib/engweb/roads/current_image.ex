defmodule Engweb.Roads.CurrentImage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roads_currentimages" do
    field :image, :string
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(current_image, attrs) do
    current_image
    |> cast(attrs, [:image, :road_id])
    |> validate_required([:image, :road_id])
  end
end
