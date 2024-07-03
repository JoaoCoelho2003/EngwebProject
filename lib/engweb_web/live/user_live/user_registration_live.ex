defmodule EngwebWeb.UserLive.UserRegistrationLive do
  use EngwebWeb, :live_view

  alias Engweb.Accounts
  alias Engweb.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="relative bg-[url('/images/braga3.jpg')] bg-no-repeat bg-cover pt-40 h-full">
      <div class="absolute inset-0 bg-white opacity-60"></div>
      <div class="relative mx-auto max-w-sm bg-gray-200 p-6 rounded-md">
        <.header class="text-center">
          Criar conta
          <:subtitle>
            Já tem conta?
            <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
              Faça login
            </.link>
            na sua conta agora.
          </:subtitle>
        </.header>

        <.simple_form_login
          for={@form}
          id="registration_form"
          phx-submit="save"
          phx-change="validate"
          phx-trigger-action={@trigger_submit}
          action={~p"/users/log_in?_action=registered"}
          method="post"
        >
          <.error :if={@check_errors}>
            Ops, algo deu errado! Verifique os erros abaixo.
          </.error>

          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Palavra-passe" required />
          <.input field={@form[:name]} type="text" label="Nome" required />
          <.input field={@form[:filiation]} type="select" label="Filiação" multiple={false} prompt="Select a filiation" options={[{"student", "student"},{"teacher", "teacher"}]} value="student" required />
          <:actions>
            <.button phx-disable-with="Creating account..." class="w-full">Crie uma conta</.button>
          </:actions>
        </.simple_form_login>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
