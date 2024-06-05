defmodule Engweb.Repo.Seeds.Roads do

  alias Engweb.Roads
  alias Engweb.Roads.Road
  alias Engweb.Repo
  alias Engweb.Accounts

  @roads File.read!("priv/fake/roads.json") |> Jason.decode!()

  def run do
    case Repo.all(Road) do
      [] ->
        seed_roads(@roads)

      _ ->
        Mix.shell().error("Found roads, aborting seeding roads.")
    end
  end

  def seed_roads(roads) do
    admin = Accounts.get_one_user_by_role("admin")

    roads
    |> Enum.each(fn road ->
      road_entry = %{
        num: road["numero"],
        name: road["nome"],
        description: road["descricao"],
        user_id: admin.id
      } |> Roads.create_road()

      id_road = Roads.get_road_by_num(road["numero"]).id

      road["figuras"] |> Enum.each(fn fig ->
        Roads.create_image(%{
          image: fig["imagem"],
          legenda: fig["legenda"],
          road_id: id_road
        })
      end)

      road["casas"] |> Enum.each(fn house ->
        Roads.create_house(%{
          num: house["numero"],
          enfiteuta: house["enfiteuta"],
          foro: house["foro"],
          description: house["descricao"],
          road_id: id_road
        })
      end)

      road["figuras_atuais"] |> Enum.each(fn fig ->
        Roads.create_current_image(%{
          image: fig["imagem"],
          road_id: id_road
        })
      end)
    end)
  end
end

Engweb.Repo.Seeds.Roads.run()
