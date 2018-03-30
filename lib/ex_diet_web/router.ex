defmodule ExDietWeb.Router do
  use ExDietWeb, :router

  pipeline :graphql do
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExDietWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: ExDietWeb.GraphQL.Schema)

    unless Mix.env() == :prod do
      forward("/graphiql", Absinthe.Plug.GraphiQL, schema: ExDietWeb.GraphQL.Schema, interface: :advanced)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExDietWeb do
  #   pipe_through :api
  # end
end
