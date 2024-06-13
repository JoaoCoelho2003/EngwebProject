defmodule EngwebWeb.RoadLive.Show do
  use EngwebWeb, :live_view

  alias Engweb.Roads
  alias Engweb.Repo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(unsigned_params, _, socket) do
    id = unsigned_params["id"]
    road = Roads.get_road!(id) |> Repo.preload([:images, :current_images, :houses, :comments])

    comments_with_users = Enum.map(road.comments, fn comment ->
      user = Roads.get_user!(comment.user_id)
      Map.put(comment, :user_name, user.name)
    end)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:road, road)
      |> assign(:images, road.images)
      |> assign(:current_images, road.current_images)
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
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("add_comment", %{"comment" => comment_text}, socket) do
    case Roads.create_comment(%{
      comment: comment_text,
      likes: 0,
      dislikes: 0,
      road_id: socket.assigns.road.id,
      user_id: socket.assigns.current_user.id
    }) do
      {:ok, comment} ->
        user = Roads.get_user!(comment.user_id)
        comment_with_user = Map.put(comment, :user_name, user.name)
        updated_comments = [comment_with_user | socket.assigns.comments]
        {:noreply, assign(socket, comments: updated_comments, new_comment: %Roads.Comment{})}
      {:error, changeset} ->
        {:noreply, assign(socket, new_comment: changeset)}
    end
  end

  defp has_voted(user_id, comment_id) do
    comment = Roads.get_comment!(comment_id)

    if comment.likes > 0 && Enum.any?(comment.likes_by, &(&1 == user_id)) do
      {:already_voted, :likes}
    elsif comment.dislikes > 0 && Enum.any?(comment.dislikes_by, &(&1 == user_id)) do
      {:already_voted, :dislikes}
    else
      {:not_voted, nil}
    end
  end

  def handle_event("vote_comment", %{"comment_id" => comment_id, "vote" => "up"}, socket) do
    comment = Roads.get_comment!(comment_id)

    case has_voted(socket.assigns.current_user.id, comment_id) do
      {:already_voted, :likes} ->
        updated_comment = %{likes: comment.likes - 1}
        Roads.update_comment(comment, updated_comment)
        {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => nil})}
      {:already_voted, _} ->
        updated_comment = %{likes: comment.likes + 1}
        Roads.update_comment(comment, updated_comment)
        {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => "up"})}
      {:not_voted, _} ->
        updated_comment = %{likes: comment.likes + 1}
        case Roads.update_comment(comment, updated_comment) do
          {:ok, _updated_comment} ->
            {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => "up"})}
          {:error, _changeset} ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("vote_comment", %{"comment_id" => comment_id, "vote" => "down"}, socket) do
    comment = Roads.get_comment!(comment_id)

    case has_voted(socket.assigns.current_user.id, comment_id) do
      {:already_voted, :dislikes} ->
        updated_comment = %{dislikes: comment.dislikes - 1}
        Roads.update_comment(comment, updated_comment)
        {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => nil})}
      {:already_voted, _} ->
        updated_comment = %{dislikes: comment.dislikes + 1}
        Roads.update_comment(comment, updated_comment)
        {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => "down"})}
      {:not_voted, _} ->
        updated_comment = %{dislikes: comment.dislikes + 1}
        case Roads.update_comment(comment, updated_comment) do
          {:ok, _updated_comment} ->
            {:noreply, push_event(socket, "comment_voted", %{"comment_id" => comment_id, "vote" => "down"})}
          {:error, _changeset} ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("delete_comment", %{"comment_id" => comment_id}, socket) do
    comment = Roads.get_comment!(comment_id)

    case Roads.delete_comment(comment) do
      {:ok, _} ->
        {:noreply, socket}
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Road"
  defp page_title(:edit), do: "Edit Road"
  defp page_title(:delete), do: "Delete Road"
  defp page_title(:delete_image), do: "Delete Image"
  defp page_title(:delete_current_image), do: "Delete Current Image"
  defp page_title(:new_image), do: "New Image"
  defp page_title(:new_current_image), do: "New Current Image"
end
