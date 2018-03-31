defmodule ExDietWeb.GraphQL.Queries.Accounts do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Middleware.RequireAuth

  object :accounts_queries do
    field :me, :user do
      middleware(RequireAuth)

      resolve(fn _, _, %{context: %{user: user}} ->
        {:ok, user}
      end)
    end
  end
end
