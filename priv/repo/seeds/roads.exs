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
      %{
        name: road["nome"],
        description: road["descricao"],
        user_id: admin.id
      } |> Roads.create_road()

      road["figuras"] |> Enum.each(fn fig ->
        {name, mem_type} = get_mem_type_and_name(fig, :images)
        Roads.create_image(%{
          image:  %Plug.Upload{
            content_type: "image/" <> mem_type,
            filename: name <> "." <> mem_type,
            path: fig["imagem"]
          },
          legenda: fig["legenda"],
          road_id: road["numero"]
        })
      end)

      road["casas"] |> Enum.each(fn house ->
        Roads.create_house(%{
          num: house["numero"],
          enfiteuta: house["enfiteuta"],
          foro: house["foro"],
          description: house["descricao"],
          road_id: road["numero"]
        })
      end)

      road["figuras_atuais"] |> Enum.each(fn fig ->
        {name, mem_type} = get_mem_type_and_name(fig, :current_images)

        Roads.create_current_images(%{
          image: %Plug.Upload{
            content_type: mem_type,
            filename: name <> "." <> mem_type,
            path: fig["imagem"]
          },
          road_id: road["numero"]
        })
      end)
    end)
  end

  defp get_mem_type_and_name(fig, :images) do
    # Extract the path from the map
    path = fig["imagem"]

    # Use Regex to extract the parts
    regex = ~r{MapaRuas-materialBase/imagem/(?<name>.+)\.(?<mem_type>[^.]+)}

    case Regex.named_captures(regex, path) do
      %{"name" => name, "mem_type" => mem_type} -> {name, mem_type}
      _ -> {:error, "Invalid format"}
    end
  end

  defp get_mem_type_and_name(fig, :current_images) do
        # Extract the path from the map
        path = fig["imagem"]

        # Use Regex to extract the parts
        regex = ~r{MapaRuas-materialBase/atual/(?<name>.+)\.(?<mem_type>[^.]+)}

        case Regex.named_captures(regex, path) do
          %{"name" => name, "mem_type" => mem_type} -> {name, mem_type}
          _ -> {:error, "Invalid format"}
        end
  end
end

Engweb.Repo.Seeds.Roads.run()
