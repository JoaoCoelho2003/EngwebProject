defmodule EngwebWeb.RoadLive.FormHouses do
  use EngwebWeb, :live_component

  alias Engweb.Roads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex justify-between">
        <.header>
          <%= @title %>
        </.header>
        <.button
          phx-click="add_house"
          phx-target={@myself}
          class="mr-2"
        >
          Adicionar Casa
        </.button>
      </div>
      <%= if @num_houses == -1 do %>
        <p>
          Ainda não foram adicionadas casas
        </p>
      <% else %>
        <%= for {form, index} <- Enum.with_index(@form_houses) do %>
          <hr class="mt-4"/>
          <div class="flex justify-between">
            <p class="text-lg font-bold mt-2">Casa <%= index + 1 %></p>
            <button
              phx-click="remove_house"
              phx-value-index={index}
              phx-target={@myself}
              class={[
                "phx-submit-loading:opacity-75 rounded-lg bg-red-600 hover:bg-red-700 py-2 px-3 mt-2",
                "text-sm font-semibold leading-6 text-white active:text-white/80"
              ]}
            >
              Remover
            </button>
          </div>
          <.simple_form
            for={form}
            id={"form_" <> Integer.to_string(index)}
            phx-change="validate"
            phx-value-index={index}
            phx-target={@myself}
          >
            <.input field={form[:num]} type="text" label="Num"/>
            <.input field={form[:enfiteuta]} type="text" label="Enfiteuta"/>
            <.input field={form[:foro]} type="text" label="Foro"/>
            <.input field={form[:description]} type="textarea" label="Descrição"/>
          </.simple_form>
        <% end %>
      <% end %>
      <%= if @error do %>
        <p class="text-red-500 mt-2">
          <%= @error %>
        </p>
      <% end %>
      <.button
        phx-click="save_houses"
        phx-target={@myself}
        class="mt-2"
        phx-disable-with="Saving..."
      >
        Guardar Casas
      </.button>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
      socket
        |> assign(:form_houses, [])
        |> assign(:num_houses, -1)
        |> assign(:error, nil)
        |> assign(assigns)
    }
  end

  @impl true
  def handle_event("add_house", _params, socket) do
    num_houses = socket.assigns[:num_houses] + 1
    {:noreply, assign_form_houses(socket) |> assign(:num_houses, num_houses)}
  end

  def handle_event("save_houses", _unsigned_params, socket) do
    if (socket.assigns.current_user.id != socket.assigns.road.user_id) and (socket.assigns.current_user.role != "admin") do
      {:noreply, socket |> put_flash(:error, "Não estás autorizado a realizar esta ação")}
    else
      create_houses(socket)
    end
  end

  def handle_event("validate", %{"houses" => house, "index" => index}, socket) do
    changeset =
      Roads.change_house(%Roads.Houses{}, house)
      |> Map.put(:action, :validate)

    form = to_form(changeset)

    IO.inspect(form, label: "form")

    {:noreply, socket |> assign(:form_houses, List.replace_at(socket.assigns.form_houses, String.to_integer(index), form))}
  end

  def handle_event("remove_house", %{"index" => index}, socket) do
    form_houses = List.delete_at(socket.assigns.form_houses, String.to_integer(index))

    {:noreply, socket |> assign(:form_houses, form_houses) |> assign(:num_houses, socket.assigns.num_houses - 1)}
  end

  defp assign_form_houses(socket) do
    changeset = Roads.change_house(%Roads.Houses{
      num: nil,
      enfiteuta: nil,
      foro: nil,
      description: nil,
      road_id: socket.assigns.road.id
    })

    form = to_form(changeset)
    forms = socket.assigns.form_houses ++ [form]
    assign(socket, :form_houses, forms)
  end

  defp create_houses(socket) do
    case check_integrity_houses(socket) do
      {:ok, _} ->
        socket |> assign(:error, nil)
        IO.inspect(socket.assigns.form_houses, label: "socket.assigns.form_houses")
        houses = socket.assigns.form_houses
        Enum.each(houses, fn form ->
          %{
            num: form.params["num"] |> String.trim(),
            enfiteuta: form.params["enfiteuta"] |> String.trim(),
            foro: form.params["foro"] |> String.trim(),
            description: form.params["description"] |> String.trim(),
            road_id: socket.assigns.road.id
          } |> Roads.create_house()
        end)


        {:noreply,
        socket
        |> put_flash(:info, "Casas criadas com sucesso")
        |> push_patch(to: socket.assigns.patch)}

      {:error, _} ->
        {:noreply, socket |> assign(:error, "Existem campos vazios")}
    end
  end

  defp check_integrity_houses(socket) do
    houses = socket.assigns.form_houses
    IO.inspect(houses, label: "houses")
    Enum.reduce_while(houses, {:ok, houses}, fn form, acc ->
      params = Map.values(form.params)
      if Enum.empty?(params) or Enum.any?(params, fn param -> String.trim(param) == "" end) do
        {:halt, {:error, form}}
      else
        {:cont, acc}
      end
    end)
  end
end
