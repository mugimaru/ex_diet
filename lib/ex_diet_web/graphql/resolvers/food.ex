defmodule ExDietWeb.GraphQL.Resolvers.Food do
  @moduledoc false

  alias ExDiet.Repo
  alias ExDiet.Food
  alias Absinthe.Relay.Connection

  def list_ingredients(_parent, args, %{context: %{user: user}}) do
    Food.Ingredient
    |> Food.Queries.Ingredient.for_user_or_global(user)
    |> Food.Queries.Ingredient.search(args)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_ingredients(_parent, args, _res) do
    Food.Ingredient
    |> Food.Queries.Ingredient.global()
    |> Food.Queries.Ingredient.search(args)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_recipes(_parent, args, %{context: %{user: user}}) do
    Food.Recipe
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Recipe.search(args)
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_calendars(_parent, args, %{context: %{user: user}}) do
    {
      :ok,
      Food.Calendar
      |> Food.Queries.Calendar.for_user(user)
      |> Food.Queries.Calendar.search(args)
      |> Repo.all
    }
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

      Food.update_recipe(recipe, args)
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
      calendar = Repo.preload(calendar, meals: [:recipe, :ingredient])

      Food.update_calendar(
        calendar,
        add_persisted_items(calendar, args, :meals, fn m ->
          %{id: m.id, recipe_id: m.recipe_id, ingredient_id: m.ingredient_id, weight: m.weight}
        end)
      )
    end
  end

  def nutrient_fact(parent, _args, %{definition: %{name: field}}) do
    {:ok, ExDiet.Food.NutritionFacts.calculate_one(parent, String.to_existing_atom(field))}
  end

  defp add_persisted_items(entity, args, assoc_name, fun) do
    case args[assoc_name] do
      nil ->
        args

      [] ->
        args

      list ->
        ids = list |> Enum.map(& &1[:id]) |> Enum.reject(&is_nil/1)
        persisted = Enum.reject(Map.get(entity, assoc_name), &(&1.id in ids))
        Map.put(args, assoc_name, list ++ Enum.map(persisted, fun))
    end
  end
end
