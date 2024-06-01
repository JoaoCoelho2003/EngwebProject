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

  defp save_road(socket, :edit, road_params) do
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

  defp save_road(socket, :new, road_params) do
    case Roads.create_road(road_params) do
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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
