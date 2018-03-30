defmodule ExDietWeb.GraphQL.Mutations.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Resolvers.Food, as: Resolver

  input_object :create_ingredient_input do
    field(:name, non_null(:string))
    field(:protein, non_null(:decimal))
    field(:fat, non_null(:decimal))
    field(:carbonhydrate, non_null(:decimal))
    field(:energy, non_null(:decimal))
  end

  input_object :update_ingredient_input do
    field(:name, :string)
    field(:protein, :decimal)
    field(:fat, :decimal)
    field(:carbonhydrate, :decimal)
    field(:energy, :decimal)
  end

  object :food_mutations do
    field :create_ingredient, :ingredient do
      arg(:input, non_null(:create_ingredient_input))

      resolve(&Resolver.create_ingredient/3)
    end

    field :update_ingredient, :ingredient do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_ingredient_input))

      resolve(&Resolver.update_ingredient/3)
    end

    field :delete_ingredient, :ingredient do
      arg(:id, non_null(:id))

      resolve(&Resolver.delete_ingredient/3)
    end
  end
end
