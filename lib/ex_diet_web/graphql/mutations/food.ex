defmodule ExDietWeb.GraphQL.Mutations.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Resolvers.Food, as: Resolver
  alias ExDietWeb.GraphQL.Middleware.RequireAuth
  alias Absinthe.Relay.Node.ParseIDs

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

  input_object :recipe_ingredient_input do
    field(:id, :id)
    field(:weight, non_null(:integer))
    field(:ingredient_id, :id)
    field(:ingredient, :create_ingredient_input)
  end

  input_object :meal_input do
    field(:id, :id)
    field(:weight, non_null(:integer))
    field(:ingredient_id, :id)
    field(:recipe_id, :id)
  end

  input_object :create_recipe_input do
    field(:name, non_null(:string))
    field(:description, :string)
    field(:weight_cooked, :integer)
    field(:recipe_ingredients, list_of(:recipe_ingredient_input))
  end

  input_object :update_recipe_input do
    field(:name, :string)
    field(:description, :string)
    field(:weight_cooked, :integer)
    field(:recipe_ingredients, list_of(:recipe_ingredient_input))
  end

  input_object :create_calendar_input do
    field(:day, non_null(:date))
    field(:meals, list_of(:meal_input))
  end

  input_object :update_calendar_input do
    field(:day, :date)
    field(:meals, list_of(:meal_input))
  end

  object :food_mutations do
    field :create_ingredient, :ingredient do
      arg(:input, non_null(:create_ingredient_input))

      middleware(RequireAuth)
      resolve(&Resolver.create_ingredient/3)
    end

    field :update_ingredient, :ingredient do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_ingredient_input))

      middleware(ParseIDs, id: :ingredient)
      middleware(RequireAuth)
      resolve(&Resolver.update_ingredient/3)
    end

    field :delete_ingredient, :ingredient do
      arg(:id, non_null(:id))

      middleware(ParseIDs, id: :ingredient)
      middleware(RequireAuth)
      resolve(&Resolver.delete_ingredient/3)
    end

    field :create_recipe, :recipe do
      arg(:input, non_null(:create_recipe_input))

      middleware(RequireAuth)

      middleware(
        ParseIDs,
        input: [recipe_ingredients: [ingredient_id: :ingredient, id: :recipe_ingredient]]
      )

      resolve(&Resolver.create_recipe/3)
    end

    field :update_recipe, :recipe do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_recipe_input))

      middleware(RequireAuth)

      middleware(
        ParseIDs,
        id: :recipe,
        input: [recipe_ingredients: [ingredient_id: :ingredient, id: :recipe_ingredient]]
      )

      resolve(&Resolver.update_recipe/3)
    end

    field :delete_recipe, :recipe do
      arg(:id, non_null(:id))

      middleware(ParseIDs, id: :recipe)
      middleware(RequireAuth)
      resolve(&Resolver.delete_recipe/3)
    end

    field :create_calendar, :calendar do
      arg(:input, non_null(:create_calendar_input))

      middleware(
        ParseIDs,
        id: :calendar,
        input: [meals: [ingredient_id: :ingredient, recipe_id: :recipe, id: :meal]]
      )

      resolve(&Resolver.create_calendar/3)
    end

    field :update_calendar, :calendar do
      arg(:id, non_null(:id))
      arg(:input, non_null(:update_calendar_input))

      middleware(
        ParseIDs,
        id: :calendar,
        input: [meals: [ingredient_id: :ingredient, recipe_id: :recipe, id: :meal]]
      )

      resolve(&Resolver.update_calendar/3)
    end
  end
end
