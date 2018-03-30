defmodule ExDietWeb.Router do
  use ExDietWeb, :router

  pipeline :graphql do
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ExDietWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: ExDietWeb.GraphQL.Schema)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExDietWeb do
  #   pipe_through :api
  # end
end
