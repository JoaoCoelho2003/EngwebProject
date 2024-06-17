defmodule EngwebWeb.UserLive.UserLoginLive do
  use EngwebWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="relative bg-[url('/images/braga1.jpg')] bg-no-repeat bg-cover pt-40 h-full">
    <div class="absolute inset-0 bg-white opacity-60"></div>
      <div class="relative mx-auto max-w-sm bg-gray-200 p-6 rounded-md">
        <.header class="text-center">
          Inicie sessão na conta
          <:subtitle>
            Não tens uma conta?
            <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
              Crie
            </.link>
            uma conta agora.
          </:subtitle>
        </.header>

        <.simple_form_login for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Palavra-passe" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Mantenha-me conectado" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              Perdeste a senha?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full">
              Iniciar sessão <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form_login>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
