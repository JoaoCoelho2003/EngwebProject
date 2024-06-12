defmodule Engweb.RoadsTest do
  use Engweb.DataCase

  alias Engweb.Roads

  describe "roads" do
    alias Engweb.Roads.Road

    import Engweb.RoadsFixtures

    @invalid_attrs %{name: nil, description: nil, num: nil}

    test "list_roads/0 returns all roads" do
      road = road_fixture()
      assert Roads.list_roads() == [road]
    end

    test "get_road!/1 returns the road with given id" do
      road = road_fixture()
      assert Roads.get_road!(road.id) == road
    end

    test "create_road/1 with valid data creates a road" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Road{} = road} = Roads.create_road(valid_attrs)
      assert road.name == "some name"
      assert road.description == "some description"
    end

    test "create_road/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roads.create_road(@invalid_attrs)
    end

    test "update_road/2 with valid data updates the road" do
      road = road_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Road{} = road} = Roads.update_road(road, update_attrs)
      assert road.name == "some updated name"
      assert road.description == "some updated description"
    end

    test "update_road/2 with invalid data returns error changeset" do
      road = road_fixture()
      assert {:error, %Ecto.Changeset{}} = Roads.update_road(road, @invalid_attrs)
      assert road == Roads.get_road!(road.id)
    end

    test "delete_road/1 deletes the road" do
      road = road_fixture()
      assert {:ok, %Road{}} = Roads.delete_road(road)
      assert_raise Ecto.NoResultsError, fn -> Roads.get_road!(road.id) end
    end

    test "change_road/1 returns a road changeset" do
      road = road_fixture()
      assert %Ecto.Changeset{} = Roads.change_road(road)
    end
  end
end
