defmodule Engweb.Roads.Images do
  use Ecto.Schema
  import Ecto.Changeset

  schema "road_images" do
    field :image, :string
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(images, attrs) do
    images
    |> cast(attrs, [:image])
    |> validate_required([:image])
  end
end
