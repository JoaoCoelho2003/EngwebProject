defmodule Engweb.Roads.Images do
  use Ecto.Schema
  import Ecto.Changeset

  schema "road_images" do
    field :image, :string
    field :legenda, :string
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(images, attrs) do
    images
    |> cast(attrs, [:image, :legenda, :road_id])
    |> validate_required([:image, :legenda, :road_id])
  end
end
