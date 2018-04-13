defmodule ExDietWeb.GraphQL.Types.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  alias ExDiet.Food.{Ingredient, RecipeIngredient, Recipe, Calendar, Meal}
  alias ExDietWeb.GraphQL.Resolvers.Food, as: Resolver
  alias Absinthe.Relay.Node

  interface :eatable do
    field(:protein, non_null(:decimal))
    field(:fat, non_null(:decimal))
    field(:carbonhydrate, non_null(:decimal))
    field(:energy, non_null(:decimal))
  end

  object :eatable_fields do
    field(:protein, non_null(:decimal)) do
      resolve(&Resolver.nutrient_fact/3)
    end

    field(:fat, non_null(:decimal)) do
      resolve(&Resolver.nutrient_fact/3)
    end

    field(:carbonhydrate, non_null(:decimal)) do
      resolve(&Resolver.nutrient_fact/3)
    end

    field(:energy, non_null(:decimal)) do
      resolve(&Resolver.nutrient_fact/3)
    end
  end

  connection(node_type: :ingredient)

  node object(:ingredient) do
    field(:name, non_null(:string))
    field(:protein, non_null(:decimal))
    field(:fat, non_null(:decimal))
    field(:carbonhydrate, non_null(:decimal))
    field(:energy, non_null(:decimal))
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)

    field(:user, :user) do
      resolve(dataloader(Ingredient, :user))
    end

    field(:recipe_ingredients, list_of(:recipe_ingredient)) do
      resolve(dataloader(Ingredient, :recipe_ingredients))
    end

    interface(:eatable)
    is_type_of(:ingredient)
  end

  node object(:recipe_ingredient) do
    field(:weight, non_null(:integer))

    field(:recipe, non_null(:recipe)) do
      resolve(dataloader(RecipeIngredient, :recipe))
    end

    field(:ingredient, non_null(:ingredient)) do
      resolve(dataloader(RecipeIngredient, :ingredient))
    end

    import_fields(:eatable_fields)
    interface(:eatable)
    is_type_of(:recipe_ingredient)
  end

  connection(node_type: :recipe)

  node object(:recipe) do
    field(:name, non_null(:string))
    field(:description, :string)
    field(:weight_cooked, :integer)
    field(:eaten, :boolean)

    field(:user, :user) do
      resolve(dataloader(Recipe, :user))
    end

    field(:recipe_ingredients, list_of(:recipe_ingredient)) do
      resolve(dataloader(Recipe, :recipe_ingredients))
    end

    import_fields(:eatable_fields)
    interface(:eatable)
    is_type_of(:recipe)
  end

  node object(:calendar) do
    field(:day, non_null(:date))

    field(:user, :user) do
      resolve(dataloader(Calendar, :user))
    end

    field(:meals, list_of(:meal)) do
      resolve(dataloader(Calendar, :meals))
    end

    import_fields(:eatable_fields)
    interface(:eatable)
    is_type_of(:calendar)
  end

  node object(:meal) do
    field(:weight, non_null(:integer))

    field(:user, :user) do
      resolve(dataloader(Meal, :user))
    end

    field(:recipe_id, :id) do
      resolve(fn meal, _, _ ->
        {:ok, Node.to_global_id("Recipe", meal.recipe_id)}
      end)
    end

    field(:recipe, :recipe) do
      resolve(dataloader(Meal, :recipe))
    end

    field(:ingredient_id, :id) do
      resolve(fn meal, _, _ ->
        {:ok, Node.to_global_id("Ingredient", meal.ingredient_id)}
      end)
    end

    field(:ingredient, :ingredient) do
      resolve(dataloader(Meal, :ingredient))
    end

    import_fields(:eatable_fields)
    interface(:eatable)
    is_type_of(:meal)
  end
end
