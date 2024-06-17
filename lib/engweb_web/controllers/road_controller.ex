defmodule EngwebWeb.RoadController do
  use EngwebWeb, :controller

  alias Engweb.Roads

  def download_image(conn, %{"id" => id}) do
    road = Roads.get_road!(id) |> Engweb.Repo.preload([:images, :current_images, :houses])

    entries = get_images_entries(road.images) ++ get_images_entries(road.current_images)

    xml = generate_xml(road)

    File.write!("priv/static/uploads/road_#{id}.xml", xml)

    entries = entries ++ [Zstream.entry("road_#{id}.xml", HTTPStream.get("http://localhost:4000/uploads/road_#{id}.xml"))]

    # Collect all file paths and create a zip stream
    zip_stream = Zstream.zip(entries)
      |> Enum.to_list()

    File.rm!("priv/static/uploads/road_#{id}.xml")
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

  defp generate_xml(road) do
    begin = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rua xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="file:/C:/Users/In%C3%AAs/Desktop/4%C2%BA%20Ano%20(2018-2019)/1%C2%BA%20Semestre/Publica%C3%A7%C3%A3o%20Eletr%C3%B3nica/MRB-rua.xsd">
        <meta>
          <número>#{road.id}</número>
          <nome>#{road.name}</nome>
        </meta>
        <corpo>
    """

    descricao = """
      <para>
        #{road.description}
      </para>
    """

    figuras = get_images_xml(road.images) |> Enum.join()

    casas = get_casas_xml(road.houses) |> Enum.join()

    """
    #{begin}
          <figuras>
            #{figuras}
          </figuras>
          <lista-casas>
            #{casas}
          </lista-casas>
          #{descricao}
        </corpo>
      </rua>
    """
  end

  defp get_images_xml(images) do
    Enum.map(images, fn image ->
      name = Path.basename(Engweb.Uploaders.ImageUploader.url({image.image, image}, :original)) |> String.split("?") |> Enum.at(0)
      """
      <figura id="#{name}">
        <imagem path="#{name}"/>
        <legenda>#{image.legenda}</legenda>
      </figura>
      """
    end)
  end


  defp get_casas_xml(houses) do
    Enum.map(houses, fn house ->
    """
      <casa>
        <número>#{house.num}</número>
        <enfiteuta>#{house.enfiteuta}</enfiteuta>
        <foro>#{house.foro}</foro>
        <desc>#{house.description}</desc>
      </casa>
    """
    end)
  end
end
