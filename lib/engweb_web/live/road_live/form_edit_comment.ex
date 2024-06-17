defmodule EngwebWeb.RoadLive.FormEditComment do
  use EngwebWeb, :live_component

  alias Engweb.Roads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <h2>Editar comentário</h2>
      </.header>
      <.simple_form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
        id="edit-comment-form"
      >
        <.input field={@form[:comment]} type="textarea" label="Comment"/>
        <:actions>
          <.button phx-disable-with="Saving...">Guardar</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{comment: comment} = assigns, socket) do
    changeset = Roads.change_comment(comment)

    {:ok, socket |> assign(:form, to_form(changeset)) |> assign(assigns)}
  end

  @impl true
  def handle_event("save", %{"comment" => comment_params}, socket) do
    save_comment(socket, comment_params)
  end

  def handle_event("validate", %{"comment" => comment_params}, socket) do
    changeset =
      socket.assigns.comment
      |> Roads.change_comment(comment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end


  defp save_comment(socket, comment_params) do
    if socket.assigns.comment.user_id != socket.assigns.current_user.id do
      {:noreply, socket |> put_flash(:error, "Não estás autorizado a editar este comentário")}
    else
      case Roads.update_comment(socket.assigns.comment, comment_params) do
        {:ok, comment} ->
          notify_parent({:saved, comment})

          {:noreply,
          socket
          |> put_flash(:info, "Comentário atualizado com sucesso")
          |> push_patch(to: socket.assigns.patch)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :form, to_form(changeset))}
      end
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
