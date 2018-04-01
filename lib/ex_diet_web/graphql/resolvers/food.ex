defmodule ExDietWeb.GraphQL.Resolvers.Food do
  @moduledoc false

  alias ExDiet.Repo
  alias ExDiet.Food

  def list_ingredients(_parent, args, _resolution) do
    Absinthe.Relay.Connection.from_query(Food.Ingredient, &Repo.all/1, args)
  end

  def create_ingredient(_, %{input: args}, %{context: %{user: user}}) do
    args
    |> Map.put_new(:user_id, user.id)
    |> Food.create_ingredient()
  end

  def update_ingredient(_, %{id: id, input: args}, _) do
    with {:ok, ingredient} <- Repo.fetch(Food.Ingredient, id) do
      Food.update_ingredient(ingredient, args)
    end
  end

  def delete_ingredient(_, %{id: id}, _) do
    with {:ok, ingredient} <- Repo.fetch(Food.Ingredient, id) do
      Food.delete_ingredient(ingredient)
    end
  end

  def create_recipe(_, %{input: args}, %{context: %{user: user}}) do
    args
    |> Map.put_new(:user_id, user.id)
    |> Food.create_recipe()
  end

  def update_recipe(_, %{id: id, input: args}, _) do
    with {:ok, recipe} <- Repo.fetch(Food.Recipe, id) do
      recipe = Repo.preload(recipe, :recipe_ingredients)
      Food.update_recipe(recipe, add_persisted_recipe_ingredients(recipe, args))
    end
  end

  def delete_recipe(_, %{id: id}, _) do
    with {:ok, recipe} <- Repo.fetch(Food.Recipe, id) do
      Food.delete_recipe(recipe)
    end
  end

  def create_calendar(_, %{input: args}, %{context: %{user: user}}) do
    args
    |> Map.put_new(:user_id, user.id)
    |> Food.create_calendar()
  end

  def update_calendar(_, %{id: id, input: args}, _) do
    with {:ok, calendar} <- Repo.fetch(Food.Calendar, id) do
      Food.update_calendar(calendar, args)
    end
  end

  def nutrient_fact(parent, _args, %{definition: %{name: field}}) do
    {:ok, ExDiet.Food.NutritionFacts.calculate_one(parent, String.to_existing_atom(field))}
  end

  defp add_persisted_recipe_ingredients(recipe, %{recipe_ingredients: list} = args) when is_list(list) do
    ids = list |> Enum.map(& &1[:id]) |> Enum.reject(&is_nil/1)
    ingredients = Enum.reject(recipe.recipe_ingredients, &(&1.id in ids))

    ri =
      list ++
        Enum.map(ingredients, fn ri ->
          %{id: ri.id, recipe_id: ri.recipe_id, ingredient_id: ri.ingredient_id}
        end)

    Map.put(args, :recipe_ingredients, ri)
  end

  defp add_persisted_recipe_ingredients(_recipe, args), do: args
end
