defmodule ExDiet.Food do
  @moduledoc """
  The Food context.
  """

  import Ecto.Query, warn: false
  alias ExDiet.Repo

  alias ExDiet.Food.{Recipe, Ingredient}

  def create_ingredient(attrs \\ %{}) do
    %Ingredient{}
    |> Ingredient.changeset(attrs)
    |> Repo.insert()
  end

  def update_ingredient(%Ingredient{} = ingredient, attrs) do
    ingredient
    |> Ingredient.changeset(attrs)
    |> Repo.update()
  end

  def delete_ingredient(%Ingredient{} = ingredient) do
    Repo.delete(ingredient)
  end

  def create_recipe(attrs \\ %{}) do
    %Recipe{}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
  end

  def update_recipe(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  def delete_recipe(%Recipe{} = recipe) do
    Repo.delete(recipe)
  end
end
