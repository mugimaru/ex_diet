defmodule ExDietWeb.GraphQL.Queries.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Resolvers.Food, as: Resolver

  object :food_queries do
    connection field(:list_ingredients, node_type: :ingredient) do
      arg(:filter, :string)

      resolve(&Resolver.list_ingredients/3)
    end
  end
end
