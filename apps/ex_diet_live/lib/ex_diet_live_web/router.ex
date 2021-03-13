defmodule ExDietLiveWeb.Router do
  use ExDietLiveWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {ExDietLiveWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(ExDietLiveWeb.Plugs.Auth)
  end

  pipeline :authenticated do
    plug(ExDietLiveWeb.Plugs.Auth, :require_authenticated)
  end

  pipeline :anonymous do
    plug(ExDietLiveWeb.Plugs.Auth, :require_anonymous)
  end

  scope "/", ExDietLiveWeb do
    pipe_through(:browser)
    live("/", PageLive, :index)

    scope "/accounts", Account, as: :account do
      pipe_through(:anonymous)

      resources("/", RegistrationController, only: [:new, :create])
      resources("/sessions", SessionController, only: [:new, :create])
    end
  end

  scope "/", ExDietLiveWeb do
    pipe_through(:browser)
    pipe_through(:authenticated)

    delete("/accounts/sessions", Account.SessionController, :delete, as: :account_session)

    scope "/food", Food do
      live("/ingredients", IngredientLive, :index)
      live("/recipes", RecipeLive, :index)
    end
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: ExDietLiveWeb.Telemetry)
    end
  end
end
