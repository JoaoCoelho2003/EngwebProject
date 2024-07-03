defmodule EngwebWeb.RoadLive.Show do
  use EngwebWeb, :live_view

  alias Engweb.Roads
  alias Engweb.Repo
  alias Engweb.Roads.Houses
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(unsigned_params, _, socket) do
    id = unsigned_params["id"]
    road = Roads.get_road!(id) |> Repo.preload([:images, :current_images, :houses, comments: [:reactions]])

    comments_with_users = join_comments_with_users(road.comments)

    comments_with_users = add_likes_dislikes(comments_with_users)

    images = Enum.map(road.images, &get_image_url/1)

    current_images = Enum.map(road.current_images, &get_image_url/1)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:road, road)
      |> assign(:images, images)
      |> assign(:current_images, current_images)
      |> assign(:max_image_uploads, Roads.max_image_uploads())
      |> assign(:max_current_image_uploads, Roads.max_current_image_uploads())
      |> assign(:houses, road.houses)
      |> assign(:comments, comments_with_users)
      |> assign(:new_comment, %Roads.Comment{})

    case socket.assigns.live_action do
      :delete_image ->
        image_id = unsigned_params["image_id"]
        {:noreply, socket |> assign(:image, image_id)}
      :delete_current_image ->
        current_image_id = unsigned_params["current_image_id"]
        {:noreply, socket |> assign(:current_image, current_image_id)}
      :delete_house ->
        house_id = unsigned_params["house_id"]
        {:noreply, socket |> assign(:house, house_id)}
      :new_house ->
        {:noreply, socket |> assign(:house, %Houses{})}
      :edit_house ->
        house_id = unsigned_params["house_id"]
        house = Enum.find(road.houses, &(&1.id == String.to_integer(house_id)))
        {:noreply, socket |> assign(:house, house)}
      :edit_comment ->
        comment_id = unsigned_params["comment_id"]
        comment = Roads.get_comment!(comment_id)
        {:noreply, socket |> assign(:comment, comment)}
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_comment", %{"comment" => comment_text}, socket) do
    case Roads.create_comment(%{
      comment: comment_text,
      road_id: socket.assigns.road.id,
      user_id: socket.assigns.current_user.id,
    }) do
      {:ok, comment} ->
        user = Roads.get_user!(comment.user_id)
        comment_with_user = Map.put(comment, :user_name, user.name) |> Map.put(:likes, 0) |> Map.put(:dislikes, 0)

        updated_comments = [comment_with_user | socket.assigns.comments]

        {:noreply, assign(socket, comments: updated_comments, new_comment: %Roads.Comment{})}
      {:error, changeset} ->
        {:noreply, assign(socket, new_comment: changeset)}
    end
  end

  @impl true
  def handle_event("vote_comment", %{"comment_id" => comment_id, "vote" => vote}, socket) do
    user_id = socket.assigns.current_user.id

    existing_reaction = Repo.get_by(Roads.Reaction, user_id: user_id, comment_id: comment_id)

    cond do
      existing_reaction && existing_reaction.reaction_type == vote ->
        case Roads.delete_reaction(existing_reaction) do
          {:ok, _} ->
            {:noreply, update_comment_reactions(socket)}
          {:error, _} ->
            {:noreply, socket}
        end

      existing_reaction && existing_reaction.reaction_type != vote ->
        changeset = Roads.Reaction.changeset(existing_reaction, %{reaction_type: vote})
        case Repo.update(changeset) do
          {:ok, _} ->
            {:noreply, update_comment_reactions(socket)}
          {:error, _} ->
            {:noreply, socket}
        end

      true ->
        case Roads.create_reaction(%{
          reaction_type: vote,
          comment_id: comment_id,
          user_id: user_id
        }) do
          {:ok, _reaction} ->
            {:noreply, update_comment_reactions(socket)}
          {:error, _changeset} ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("delete_comment", %{"comment_id" => comment_id}, socket) do
    comment = Roads.get_comment!(comment_id)

    case Roads.delete_comment(comment) do
      {:ok, _} ->
        {:noreply, socket |> assign(:comments, Enum.filter(socket.assigns.comments, fn c -> c.id != String.to_integer(comment_id) end))}
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp join_comments_with_users(comments) do
    Enum.map(comments, &join_comment_with_reactions/1)
  end

  defp join_comment_with_reactions(comment) do
    user = Roads.get_user!(comment.user_id)

    reactions = Repo.all(from r in Roads.Reaction, where: r.comment_id == ^comment.id)
    comment_with_reactions =
      Map.put(comment, :reactions, reactions |> Enum.to_list())

    Map.put(comment_with_reactions, :user_name, user.name)
  end

  defp update_comment_reactions(socket) do
    road_id = socket.assigns.road.id
    road = Roads.get_road!(road_id) |> Repo.preload([comments: [:reactions]])

    comments_with_users = join_comments_with_users(road.comments)

    comments_with_users = add_likes_dislikes(comments_with_users)

    assign(socket, comments: comments_with_users)
  end

  defp page_title(:show), do: "Show Road"
  defp page_title(:edit), do: "Edit Road"
  defp page_title(:delete), do: "Delete Road"
  defp page_title(:delete_image), do: "Delete Image"
  defp page_title(:delete_current_image), do: "Delete Current Image"
  defp page_title(:new_image), do: "New Image"
  defp page_title(:new_current_image), do: "New Current Image"
  defp page_title(:delete_house), do: "Delete House"
  defp page_title(:edit_house), do: "Edit House"
  defp page_title(:new_house), do: "New House"
  defp page_title(:edit_comment), do: "Edit Comment"

  defp add_likes_dislikes(comments) do
    Enum.map(comments, &count_likes_dislikes/1)
  end

  defp count_likes_dislikes(comment) do
    likes = Enum.filter(comment.reactions, fn r -> r.reaction_type == "like" end)
    dislikes = Enum.filter(comment.reactions, fn r -> r.reaction_type == "dislike" end)
    Map.put(comment, :likes, Enum.count(likes))
    |> Map.put(:dislikes, Enum.count(dislikes))
  end

  defp get_image_url(image),
    do: {image, Engweb.Uploaders.ImageUploader.url({image.image, image})}
end
