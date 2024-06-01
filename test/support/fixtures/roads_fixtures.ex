defmodule Engweb.RoadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Engweb.Roads` context.
  """

  @doc """
  Generate a road.
  """
  def road_fixture(attrs \\ %{}) do
    {:ok, road} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        num: 42
      })
      |> Engweb.Roads.create_road()

    road
  end
end
