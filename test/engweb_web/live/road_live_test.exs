defmodule EngwebWeb.RoadLiveTest do
  use EngwebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Engweb.RoadsFixtures

  @create_attrs %{name: "some name", description: "some description", num: 42}
  @update_attrs %{name: "some updated name", description: "some updated description", num: 43}
  @invalid_attrs %{name: nil, description: nil, num: nil}

  defp create_road(_) do
    road = road_fixture()
    %{road: road}
  end

  describe "Index" do
    setup [:create_road]

    test "lists all roads", %{conn: conn, road: road} do
      {:ok, _index_live, html} = live(conn, ~p"/roads")

      assert html =~ "Listing Roads"
      assert html =~ road.name
    end

    test "saves new road", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/roads")

      assert index_live |> element("a", "New Road") |> render_click() =~
               "New Road"

      assert_patch(index_live, ~p"/roads/new")

      assert index_live
             |> form("#road-form", road: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#road-form", road: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/roads")

      html = render(index_live)
      assert html =~ "Road created successfully"
      assert html =~ "some name"
    end

    test "updates road in listing", %{conn: conn, road: road} do
      {:ok, index_live, _html} = live(conn, ~p"/roads")

      assert index_live |> element("#roads-#{road.id} a", "Edit") |> render_click() =~
               "Edit Road"

      assert_patch(index_live, ~p"/roads/#{road}/edit")

      assert index_live
             |> form("#road-form", road: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#road-form", road: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/roads")

      html = render(index_live)
      assert html =~ "Road updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes road in listing", %{conn: conn, road: road} do
      {:ok, index_live, _html} = live(conn, ~p"/roads")

      assert index_live |> element("#roads-#{road.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#roads-#{road.id}")
    end
  end

  describe "Show" do
    setup [:create_road]

    test "displays road", %{conn: conn, road: road} do
      {:ok, _show_live, html} = live(conn, ~p"/roads/#{road}")

      assert html =~ "Show Road"
      assert html =~ road.name
    end

    test "updates road within modal", %{conn: conn, road: road} do
      {:ok, show_live, _html} = live(conn, ~p"/roads/#{road}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Road"

      assert_patch(show_live, ~p"/roads/#{road}/show/edit")

      assert show_live
             |> form("#road-form", road: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#road-form", road: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/roads/#{road}")

      html = render(show_live)
      assert html =~ "Road updated successfully"
      assert html =~ "some updated name"
    end
  end
end
