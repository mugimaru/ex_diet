defmodule ExDietWeb.Router do
  use ExDietWeb, :router

  pipeline :graphql do
    plug(ExDietWeb.GraphQL.Plug.TokenAuth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api" do
    pipe_through(:graphql)

    forward("/graphql", Absinthe.Plug, schema: ExDietWeb.GraphQL.Schema)
  end
end
