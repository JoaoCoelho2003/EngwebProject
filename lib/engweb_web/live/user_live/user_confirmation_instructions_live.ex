defmodule EngwebWeb.UserLive.UserConfirmationInstructionsLive do
  use EngwebWeb, :live_view

  alias Engweb.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Nenhuma instrução de confirmação foi recebida?
        <:subtitle>Enviaremos um novo link de confirmação para o teu email</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Reenviar instruções de confirmação
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Registar</.link>
        | <.link href={~p"/users/log_in"}>Iniciar Sessão</.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      "Caso o teu e-mail esteja no nosso sistema e ainda não tenha sido confirmado, receberás em breve um e-mail com instruções."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
