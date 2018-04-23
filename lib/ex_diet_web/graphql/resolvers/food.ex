defmodule ExDietWeb.GraphQL.Resolvers.Food do
  @moduledoc false

  alias ExDiet.Repo
  alias ExDiet.Food
  alias Absinthe.Relay.Connection

  def list_ingredients(_parent, args, %{context: %{user: user}}) do
    Food.Ingredient
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Ingredient.search(args)
    |> Food.Queries.Ingredient.recent_first()
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_recipes(_parent, args, %{context: %{user: user}}) do
    Food.Recipe
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Recipe.search(args)
    |> Food.Queries.Ingredient.recent_first()
    |> Connection.from_query(&Repo.all/1, args)
  end

  def list_calendars(_parent, args, %{context: %{user: user}}) do
    {
      :ok,
      Food.Calendar
      |> Food.Queries.Calendar.for_user(user)
      |> Food.Queries.Calendar.search(args)
      |> Repo.all()
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
      Food.update_calendar(calendar, args)
    end
  end

  def nutrient_fact(parent, _args, %{definition: %{name: field}}) do
    {:ok, ExDiet.Food.NutritionFacts.calculate_one(parent, String.to_existing_atom(field))}
  end
end
