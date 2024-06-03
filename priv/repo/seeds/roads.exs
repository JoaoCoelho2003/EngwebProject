defmodule Engweb.Repo.Seeds.Roads do

  alias Engweb.Roads
  alias Engweb.Roads.Road
  alias Engweb.Repo

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
    roads
    |> Enum.each(fn road ->
      road_entry = %{
        num: road["numero"],
        name: road["nome"],
        description: road["descricao"]
      }

      case Roads.create_road(road_entry) do
        {:ok, changeset} ->
          Repo.update!(changeset)

        {:error, changeset} ->
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end

      id_road = Roads.get_road_by_num(road["numero"]).id

      road_entry["figuras"] |> Enum.each(fn fig ->
        fig = %{
          image: fig["imagem"],
          legenda: fig["legenda"],
          road_id: id_road
        }

        case Roads.create_image(fig) do
          {:ok, changeset} ->
            Repo.update!(changeset)

          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
        end
      end)

      road_entry["casas"] |> Enum.each(fn house ->
        house = %{
          num: house["numero"],
          enfiteuta: house["enfiteuta"],
          foro: house["foro"],
          description: house["descricao"],
          road_id: id_road
        }

        case Roads.create_house(house) do
          {:ok, changeset} ->
            Repo.update!(changeset)

          {:error, changeset} ->
            Mix.shell().error(Kernel.inspect(changeset.errors))
        end
      end)
    end)
  end
end

Engweb.Repo.Seeds.Roads.run()
