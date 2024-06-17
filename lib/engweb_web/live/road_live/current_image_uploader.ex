defmodule EngwebWeb.RoadLive.CurrentImageUploader do
  @moduledoc """
  An image uploader component that allows you to upload an image.
  The component attributes are:
    @uploads - the uploads object
    @target - the target to send the event to

  The component events the parent component should define are:
    cancel-current-image - cancels the upload of an image. This event should be defined in the component that you passed in the @target attribute.
  """
  use EngwebWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div class="shrink-0 1.5xl:shrink-0">
        <.live_file_input upload={@uploads.current_image} class="hidden" />
        <div class={
            "#{if length(@uploads.current_image.entries) >= @uploads.current_image.max_entries do
              "hidden"
            end} border-2 border-gray-300 border-dashed rounded-md"
          } phx-drop-target={@uploads.current_image.ref}>
          <div class="mx-auto sm:col-span-6 lg:w-full">
            <div class="my-[140px] flex justify-center px-6">
              <div class="space-y-1 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48" aria-hidden="true">
                  <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
                <div class="flex text-sm text-gray-600">
                  <label for="file-upload" class="relative cursor-pointer rounded-md font-medium text-orange-500 hover:text-red-800">
                    <a onclick={"document.getElementById('#{@uploads.current_image.ref}').click()"}>
                      Carregue um ficheiro
                    </a>
                  </label>
                  <p class="pl-1">ou arraste e solte</p>
                </div>
                <p class="text-xs text-gray-500">
                  PNG, JPG, GIF até 8MB
                </p>
                <p class="text-xs text-gray-500">
                  Máximo <%= @uploads.current_image.max_entries %> ficheiros
                </p>
              </div>
            </div>
          </div>
        </div>
        <section class="mt-2 flex gap-2">
          <%= for entry <- @uploads.current_image.entries do %>
            <div>
            <%= for err <- upload_errors(@uploads.current_image, entry) do %>
              <p class="alert alert-danger"><%= Phoenix.Naming.humanize(err) %></p>
            <% end %>
            <article class="upload-entry">
              <figure class="w-[200px]">
                <.live_img_preview entry={entry} />
                <div class="flex">
                  <figcaption>
                    <%= if String.length(entry.client_name) < 30 do %>
                      <% entry.client_name %>
                    <% else %>
                      <% String.slice(entry.client_name, 0..30) <> "... " %>
                    <% end %>
                  </figcaption>
                <button
                  type="button"
                  phx-click="cancel-current-image"
                  phx-target={@target}
                  phx-value-ref={entry.ref}
                  aria-label="cancel"
                  class="flex justify-center items-center mt-2 px-2 ml-2 rounded bg-black text-white hover:bg-zinc-700"
                >
                  Cancelar
                </button>
                </div>
              </figure>
            </article>
            </div>
          <% end %>
        </section>
      </div>
    </div>
    """
  end
end
