defmodule Engweb.Roads.Road do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roads" do
    field :name, :string
    field :description, :string
    field :num, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(road, attrs) do
    road
    |> cast(attrs, [:num, :name, :description])
    |> validate_required([:num, :name, :description])
  end
end
