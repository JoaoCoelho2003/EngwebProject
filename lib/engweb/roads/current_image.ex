defmodule Engweb.Roads.CurrentImages do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  schema "roads_currentimages" do
    field :image, Engweb.Uploaders.ImageUploader.Type
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(current_images, attrs) do
    current_images
    |> cast(attrs, [:road_id])
    |> cast_attachments(attrs, [:image], allow_paths: true)
    |> validate_required([:road_id])
  end
end
