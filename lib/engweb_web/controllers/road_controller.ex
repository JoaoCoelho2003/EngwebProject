defmodule EngwebWeb.RoadController do
  use EngwebWeb, :controller

  alias Engweb.Roads

  def download_image(conn, %{"id" => id}) do
    road = Roads.get_road!(id) |> Engweb.Repo.preload([:images, :current_images])

    entries = get_images_entries(road.images) ++ get_images_entries(road.current_images)

    # Collect all file paths and create a zip stream
    zip_stream = Zstream.zip(entries)
      |> Enum.to_list()

    conn
      |> put_status(:ok)
      |> send_download({:binary, zip_stream}, filename: "road_#{id}.zip")
  end

  defp get_images_entries(images) do
    images
    |> Enum.map(fn image ->
      url = Engweb.Uploaders.ImageUploader.url({image.image, image}, :original)
      name = Path.basename(url) |> String.split("?") |> Enum.at(0)
      Zstream.entry(name, HTTPStream.get("http://localhost:4000#{url}"))
    end)
  end
end
