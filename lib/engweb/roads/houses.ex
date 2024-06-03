defmodule Engweb.Roads.Houses do
  use Ecto.Schema
  import Ecto.Changeset

  schema "road_houses" do
    field :num, :string
    field :enfiteuta, :string
    field :foro, :string
    field :description, :string
    field :road_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(houses, attrs) do
    houses
    |> cast(attrs, [:num, :enfiteuta, :foro, :description])
    |> validate_required([:num, :enfiteuta, :foro, :description])
  end
end
