defmodule ExDiet.Food do
  @moduledoc """
  The Food context.
  """

  import Ecto.Query, warn: false
  alias ExDiet.Repo

  alias ExDiet.Food.Ingredient

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
end
