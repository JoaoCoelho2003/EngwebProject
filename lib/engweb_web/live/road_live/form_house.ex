defmodule EngwebWeb.RoadLive.FormHouse do
  use EngwebWeb, :live_component

  alias Engweb.Roads

  def render(assigns) do
    ~H"""
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
        <.input field={@form[:num]} type="text" label="Num"/>
        <.input field={@form[:enfiteuta]} type="text" label="Enfiteuta"/>
        <.input field={@form[:foro]} type="text" label="Foro"/>
        <.input field={@form[:description]} type="textarea" label="Description"/>
        <:actions>
          <.button
            phx-click="save"
            phx-target={@myself}
          >
            Save
          </.button>
        </:actions>
      </.simple_form>
    """
  end

  @impl true
  def update(%{house: house} = assigns, socket) do
    {:ok, assigns, socket}
  end

end
