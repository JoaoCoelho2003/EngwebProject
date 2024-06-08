defmodule Engweb.Roads do
  @moduledoc """
  The Roads context.
  """

  import Ecto.Query, warn: false
  alias Engweb.Repo

  alias Engweb.Roads.{Road, Images, Houses, CurrentImage}

  @doc """
  Returns the list of roads.

  ## Examples

      iex> list_roads()
      [%Road{}, ...]

  """
  def list_roads do
    Repo.all(Road)
  end

  @doc """
  Gets a single road.

  Raises `Ecto.NoResultsError` if the Road does not exist.

  ## Examples

      iex> get_road!(123)
      %Road{}

      iex> get_road!(456)
      ** (Ecto.NoResultsError)

  """
  def get_road!(id), do: Repo.get!(Road, id)

  @doc """
  Gets a single road by number.

  Raises `Ecto.NoResultsError` if the Road does not exist.

  ## Examples

      iex> get_road_by_num(123)
      %Road{}

      iex> get_road_by_num(456)
      ** (Ecto.NoResultsError)
  """
  def get_road_by_num(num) do
    Repo.get_by(Road, num: num)
  end

  @doc """
  Creates a road.

  ## Examples

      iex> create_road(%{field: value})
      {:ok, %Road{}}

      iex> create_road(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_road(attrs \\ %{}) do
    %Road{}
    |> Road.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a road.

  ## Examples

      iex> update_road(road, %{field: new_value})
      {:ok, %Road{}}

      iex> update_road(road, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_road(%Road{} = road, attrs) do
    road
    |> Road.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a road.

  ## Examples

      iex> delete_road(road)
      {:ok, %Road{}}

      iex> delete_road(road)
      {:error, %Ecto.Changeset{}}

  """
  def delete_road(%Road{} = road) do
    Repo.delete(road)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking road changes.

  ## Examples

      iex> change_road(road)
      %Ecto.Changeset{data: %Road{}}

  """
  def change_road(%Road{} = road, attrs \\ %{}) do
    Road.changeset(road, attrs)
  end

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_images_by_road(road_id) do
    Repo.all(from i in Images, where: i.road_id == ^road_id)
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Images, id)

  @doc """
  Creates an image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_image(attrs \\ %{}) do
    %Images{}
    |> Images.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Images{} = image, attrs) do
    image
    |> Images.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Images{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{data: %Image{}}

  """
  def list_houses_by_road(road_id) do
    Repo.all(from h in Houses, where: h.road_id == ^road_id)
  end

  @doc """
  Gets a single house.

  Raises `Ecto.NoResultsError` if the House does not exist.

  ## Examples

      iex> get_house!(123)
      %House{}

      iex> get_house!(456)
      ** (Ecto.NoResultsError)

  """
  def get_house!(id), do: Repo.get!(Houses, id)

  @doc """
  Creates a house.

  ## Examples

      iex> create_house(%{field: value})
      {:ok, %House{}}

      iex> create_house(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_house(attrs \\ %{}) do
    %Houses{}
    |> Houses.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a house.

  ## Examples

      iex> update_house(house, %{field: new_value})
      {:ok, %House{}}

      iex> update_house(house, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_house(%Houses{} = house, attrs) do
    house
    |> Houses.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a house.

  ## Examples

      iex> delete_house(house)
      {:ok, %House{}}

      iex> delete_house(house)
      {:error, %Ecto.Changeset{}}

  """
  def delete_house(%Houses{} = house) do
    Repo.delete(house)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking house changes.

  ## Examples

      iex> change_house(house)
      %Ecto.Changeset{data: %House{}}

  """
  def change_house(%Houses{} = house, attrs \\ %{}) do
    Houses.changeset(house, attrs)
  end

  @doc """
  Creates a current image.

  ## Examples

      iex> create_current_image(%{field: value})
      {:ok, %CurrentImage{}}

      iex> create_current_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_current_image(attrs \\ %{}) do
    %CurrentImage{}
    |> CurrentImage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the current image for a specific road.

  ## Examples

      iex> get_current_image_by_road(road_id)
      %CurrentImage{}

      iex> get_current_image_by_road(456)
      nil

  """
  def get_current_image_by_road(road_id) do
    Repo.one(from ci in CurrentImage, where: ci.road_id == ^road_id)
  end
end
