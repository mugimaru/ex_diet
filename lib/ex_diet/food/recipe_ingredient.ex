defmodule ExDiet.Food.RecipeIngredient do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset

  alias ExDiet.Food.{Ingredient, Recipe}

  @type t :: %__MODULE__{
          id: String.t(),
          weight: integer,
          ingredient_id: integer,
          ingredient: Ingredient.t(),
          recipe_id: integer,
          recipe: Recipe.t()
        }

  schema "recipe_ingredients" do
    field(:weight, :integer)

    belongs_to(:recipe, Recipe)
    belongs_to(:ingredient, Ingredient)
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:weight, :recipe_id, :ingredient_id])
    |> validate_required([:weight])
    |> cast_assoc(:ingredient)
    |> foreign_key_constraint(:recipe_id)
    |> foreign_key_constraint(:ingredient_id)
    |> unique_constraint(:ingredient_id, name: :recipe_ingredients_uniq_idx)
  end
end
