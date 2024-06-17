defmodule EngwebWeb.Router do
  use EngwebWeb, :router

  import EngwebWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EngwebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user

  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EngwebWeb do
    pipe_through :browser

    live_session :home,
      on_mount: [{EngwebWeb.UserAuth, :mount_current_user}] do
      live "/", RoadLive.Index, :index
    end
  end

  scope "/roads", EngwebWeb do
    pipe_through :browser

    live_session :post_roads,
      on_mount: [{EngwebWeb.UserAuth, :ensure_authenticated}] do
      live "/new", RoadLive.Index, :new
      live "/:id/houses", RoadLive.Index, :houses
      live "/:id/edit", RoadLive.Show, :edit
      live "/:id/show/edit", RoadLive.Show, :edit
      live "/:id/delete", RoadLive.Show, :delete
      live "/:id/image/:image_id/delete", RoadLive.Show, :delete_image
      live "/:id/current_image/:current_image_id/delete", RoadLive.Show, :delete_current_image
      live "/:id/image/new", RoadLive.Show, :new_image
      live "/:id/current_image/new", RoadLive.Show, :new_current_image
      live "/:id/house/:house_id/delete", RoadLive.Show, :delete_house
      live "/:id/house/:house_id/edit", RoadLive.Show, :edit_house
      live "/:id/house/new", RoadLive.Show, :new_house
      live "/:id/comment/:comment_id/edit", RoadLive.Show, :edit_comment

    end

    live_session :roads,
    on_mount: [{EngwebWeb.UserAuth, :mount_current_user}] do
      live "/:id", RoadLive.Show, :show
    end

    get "/:id/download", RoadController, :download_image
  end

  # Other scopes may use custom stacks.
  # scope "/api", EngwebWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:engweb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EngwebWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", EngwebWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{EngwebWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserLive.UserRegistrationLive, :new
      live "/users/log_in", UserLive.UserLoginLive, :new
      live "/users/reset_password", UserLive.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserLive.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", EngwebWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EngwebWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserLive.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserLive.UserSettingsLive, :confirm_email
      live "/users/:id/profile", UserLive.UserProfileLive, :user_profile
    end
  end

  scope "/", EngwebWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{EngwebWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserLive.UserConfirmationLive, :edit
      live "/users/confirm", UserLive.UserConfirmationInstructionsLive, :new
    end
  end

end
