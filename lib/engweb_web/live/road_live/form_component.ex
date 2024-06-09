defmodule EngwebWeb.RoadLive.FormComponent do
  use EngwebWeb, :live_component

  alias Engweb.Roads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage road records in your database.</:subtitle>
      </.header>
      <%= if @action == :delete do %>
        <div class="flex justify-end">
          <.simple_form
            for={@form}
            id="road-form"
            phx-target={@myself}
            phx-submit="delete"
          >
          <:actions>
            <.button phx-disable-with="Deleting..." class="bg bg-red-600 hover:bg-red-700">Delete Road</.button>
          </:actions>
      </.simple_form>
      </div>
      <% else %>
        <.simple_form
          for={@form}
          id="road-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={@form[:num]} type="number" label="Num" />
          <.input field={@form[:name]} type="text" label="Name" />
          <.input field={@form[:description]} type="text" label="Description" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Road</.button>
          </:actions>
      </.simple_form>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{road: road} = assigns, socket) do
    changeset = Roads.change_road(road)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"road" => road_params}, socket) do
    changeset =
      socket.assigns.road
      |> Roads.change_road(road_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"road" => road_params}, socket) do
    save_road(socket, socket.assigns.action, road_params)
  end

  def handle_event("delete", _params, socket) do
    delete_road(socket)
  end

  defp save_road(socket, :edit, road_params) do
    if socket.assigns.road.user_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "You are not allowed to edit this road")}
    else
      case Roads.update_road(socket.assigns.road, road_params) do
        {:ok, road} ->
          notify_parent({:saved, road})

          {:noreply,
          socket
          |> put_flash(:info, "Road updated successfully")
          |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp save_road(socket, :new, road_params) do
    if socket.assigns.current_user.id == nil do
      {:noreply, socket |> put_flash(:error, "You must be logged in to create a road")}
    else
      case Map.put(road_params, "user_id", socket.assigns.current_user.id) |> Roads.create_road() do
        {:ok, road} ->
          notify_parent({:saved, road})

          {:noreply,
          socket
          |> put_flash(:info, "Road created successfully")
          |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign_form(socket, changeset)}
      end
    end
  end

  defp delete_road(socket) do
    if socket.assigns.road.user_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "You are not allowed to delete this road")}
    else
      case Roads.delete_road(socket.assigns.road) do
        {:ok, _} ->
          notify_parent({:deleted, socket.assigns.road})

          {:noreply,
          socket
          |> put_flash(:info, "Road deleted successfully")
          |> redirect(to: socket.assigns.patch)}

        {:error, _} ->
          {:noreply, socket |> put_flash(:error, "Error deleting road")}
      end
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
