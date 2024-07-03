defmodule Engweb.Roads do
  @moduledoc """
  The Roads context.
  """

  import Ecto.Query, warn: false
  alias Engweb.Repo

  alias Engweb.Roads.{Road, Images, Houses, CurrentImages, Comment, Reaction}
  alias Engweb.Accounts.User

  @max_image_uploads 2
  @max_current_image_uploads 2

  def max_image_uploads, do: @max_image_uploads
  def max_current_image_uploads, do: @max_current_image_uploads

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

  def get_user!(id), do: Repo.get!(User, id)

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

  def list_roads_by_user_id(user_id) do
    Repo.all(from r in Road, where: r.user_id == ^user_id)
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

  def change_images(%Images{} = image, attrs \\ %{}) do
    Images.changeset(image, attrs)
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

      iex> create_current_images(%{field: value})
      {:ok, %CurrentImages{}}

      iex> create_current_images(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_current_images(attrs \\ %{}) do
    %CurrentImages{}
    |> CurrentImages.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets the current image for a specific road.

  ## Examples

      iex> get_current_images_by_road(road_id)
      %CurrentImages{}

      iex> get_current_images_by_road(456)
      nil

  """
  def list_current_images_by_road (road_id) do
    Repo.all(from ci in CurrentImages, where: ci.road_id == ^road_id)
  end

  def change_current_images(%CurrentImages{} = current_images, attrs \\ %{}) do
    CurrentImages.changeset(current_images, attrs)
  end

  def get_current_image!(id), do: Repo.get!(CurrentImages, id)

  def delete_current_image(%CurrentImages{} = current_image) do
    Repo.delete(current_image)
  end

    @doc """
  Filters roads by name.

  Returns a list of roads whose names match the given query.

  ## Examples

      iex> filter_roads_by_name("Main")
      [%Road{name: "Main Street", ...}, ...]

  """
  def filter_roads_by_name(name_query) do
    query = from(r in Road, where: ilike(r.name, ^"%#{name_query}%"))
    Repo.all(query)
  end

  def list_comments_by_road(road_id) do
    Repo.all(from c in Comment, where: c.road_id == ^road_id)
  end

  def get_comment!(id), do: Repo.get!(Comment, id)

  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  def get_comment_by_id(id) do
    Repo.get_by(Comment, id: id)
  end

  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  def delete_images_by_road(road_id) do
    Repo.delete_all(from i in Images, where: i.road_id == ^road_id)
  end

  def delete_current_images_by_road(road_id) do
    Repo.delete_all(from ci in CurrentImages, where: ci.road_id == ^road_id)
  end

  def delete_comments_by_road(road_id) do
    Repo.delete_all(from c in Comment, where: c.road_id == ^road_id)
  end

  def delete_houses_by_road(road_id) do
    Repo.delete_all(from h in Houses, where: h.road_id == ^road_id)
  end

  def list_user_roads(user_id) do
    Road
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def list_user_comments(user_id) do
    Comment
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def list_user_comments_inserted(user_id) do
    Comment
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_user_roads_inserted(user_id) do
    Road
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns reactions for a comment.

  ## Examples

      iex> get_comment_reactions(comment_id)
      %{likes: 5, dislikes: 2}

  """
  def get_comment_reactions(comment_id) do
    like_count = Repo.aggregate(from(r in Reaction, where: r.comment_id == ^comment_id and r.reaction_type == "like"), :count, :id)
    dislike_count = Repo.aggregate(from(r in Reaction, where: r.comment_id == ^comment_id and r.reaction_type == "dislike"), :count, :id)
    %{likes: like_count, dislikes: dislike_count}
  end

  @doc """
  Creates a reaction for a comment.

  ## Examples

      iex> create_reaction(%{reaction_type: "like", comment_id: comment_id, user_id: user_id})
      {:ok, %Reaction{}}

  """
  def create_reaction(attrs \\ %{}) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a reaction for a comment.

  ## Examples

      iex> update_reaction(reaction, %{reaction_type: "dislike"})
      {:ok, %Reaction{}}

  """
  def update_reaction(%Reaction{} = reaction, attrs) do
    reaction
    |> Reaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a reaction for a comment.

  ## Examples

      iex> delete_reaction(reaction)
      {:ok, %Reaction{}}

  """
  def delete_reaction(%Reaction{} = reaction) do
    Repo.delete(reaction)
  end
end
