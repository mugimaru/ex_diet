defmodule ExDiet.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: ExDiet.Repo

  def ingredient_factory do
    %ExDiet.Food.Ingredient{
      name: sequence("ingredient"),
      protein: Enum.random(1..100) * 0.31,
      fat: Enum.random(1..100) * 0.31,
      carbonhydrate: Enum.random(1..100) * 0.31,
      energy: Enum.random(100..500) * 0.31,
      user: build(:user)
    }
  end

  def user_factory do
    %ExDiet.Accounts.User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      password_hash: sequence("Password")
    }
  end

  def recipe_factory do
    %ExDiet.Food.Recipe{
      name: sequence("ingredient"),
      user: build(:user)
    }
  end

  def with_recipe(%ExDiet.Food.Calendar{} = calendar, recipe, weight) do
    insert(:recipe_meal, calendar: calendar, recipe: recipe, weight: weight)
    calendar
  end

  def with_ingredient(%ExDiet.Food.Calendar{} = calendar, ingredient, weight) do
    insert(:ingredient_meal, calendar: calendar, ingredient: ingredient, weight: weight)
    calendar
  end

  def with_ingredient(%ExDiet.Food.Recipe{} = recipe, ingredient, weight) do
    insert(:recipe_ingredient, recipe: recipe, ingredient: ingredient, weight: weight)
    recipe
  end

  def recipe_ingredient_factory do
    %ExDiet.Food.RecipeIngredient{
      recipe: build(:recipe),
      ingredient: build(:ingredient),
      weight: Enum.random(1..300)
    }
  end

  def calendar_factory do
    %ExDiet.Food.Calendar{
      day: sequence(:day, fn n -> Date.utc_today() |> Date.add(n * -1) end),
      user: build(:user)
    }
  end

  def ingredient_meal_factory do
    user = build(:user)

    %ExDiet.Food.Meal{
      position: sequence(:position, fn n -> n end),
      ingredient: build(:ingredient, user: user),
      calendar: build(:calendar, user: user)
    }
  end

  def recipe_meal_factory do
    user = build(:user)

    %ExDiet.Food.Meal{
      recipe: build(:recipe, user: user),
      calendar: build(:calendar, user: user)
    }
  end
end
