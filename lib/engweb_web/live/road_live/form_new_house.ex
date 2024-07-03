defmodule EngwebWeb.RoadLive.FormNewHouse do
  use EngwebWeb, :live_component

  alias Engweb.Roads

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <.header>
          <%= @title %>
        </.header>
        <.simple_form
          for={@form}
          id={"form_house"}
          phx-change="validate"
          phx-submit="save"
          phx-target={@myself}
        >
          <.input field={@form[:num]} type="text" label="Numero(s)"/>
          <.input field={@form[:enfiteuta]} type="text" label="Enfiteuta"/>
          <.input field={@form[:foro]} type="text" label="Foro"/>
          <.input field={@form[:description]} type="textarea" label="Descrição"/>
          <:actions>
            <.button
              phx-disable-with="Saving..."
            >
              Guardar
            </.button>
          </:actions>
        </.simple_form>
      </div>
    """
  end

  @impl true
  def update(%{house: house} = assigns, socket) do
    house = Roads.change_house(house)
    {:ok, assign(socket, :form, to_form(house)) |> assign(assigns)}
  end

  @impl true
  def handle_event("validate", %{"houses" => house_params}, socket) do
    house = Roads.change_house(socket.assigns.house,house_params) |> Map.put(:action, :validate)
    {:noreply, assign(socket, :form, to_form(house))}
  end

  def handle_event("save", %{"houses" => house_params}, socket) do
    IO.inspect(socket.assigns)
    if (socket.assigns.current_user.id != socket.assigns.road.user_id) and (socket.assigns.current_user.role != "admin") do
      {:noreply, put_flash(socket, :error, "Não estás autorizado a realizar esta ação")}
    else
      save_house(socket, house_params, socket.assigns.action)
    end
  end

  defp save_house(socket, house, :new_house) do
    case Map.put(house, "road_id", socket.assigns.road.id) |> Roads.create_house() do
      {:ok, _house} ->
        {:noreply,
        socket
          |> put_flash(:info, "Casa criada com sucesso")
          |> push_patch(to: socket.assigns.patch)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_house(socket, house, :edit_house) do
    case Roads.update_house(socket.assigns.house, house) do
      {:ok, _house} ->
        {:noreply,
        socket
          |> put_flash(:info, "Casa atualizada com sucesso")
          |> push_patch(to: socket.assigns.patch)}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
