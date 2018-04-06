defmodule ExDietWeb.GraphQL.Queries.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Resolvers.Food, as: Resolver

  input_object :calendar_filter do
    field :created_after, :datetime
    field :created_before, :datetime
    field :after, :datetime
    field :before, :datetime
  end

  object :food_queries do
    connection field(:list_ingredients, node_type: :ingredient) do
      arg(:filter, :string)

      resolve(&Resolver.list_ingredients/3)
    end

    connection field(:list_recipes, node_type: :recipe) do
      arg(:filter, :string)

      resolve(&Resolver.list_recipes/3)
    end

   field(:list_calendars, list_of(:calendar)) do
      arg :filter, :calendar_filter

      resolve(&Resolver.list_calendars/3)
    end
  end
end
