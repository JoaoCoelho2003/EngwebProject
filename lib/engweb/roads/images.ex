defmodule Engweb.Roads.Images do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "road_images" do
    field :image, Engweb.Uploaders.ImageUploader.Type
    field :legenda, :string
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(images, attrs) do
    images
    |> cast(attrs, [:legenda, :road_id])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:legenda, :road_id])
  end
end
