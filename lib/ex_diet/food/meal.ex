defmodule ExDiet.Food.Meal do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset
  alias ExDiet.Food.{Calendar, Recipe, Ingredient}

  @type t :: %__MODULE__{
          id: String.t(),
          recipe_id: integer | nil,
          recipe: Recipe.t() | nil,
          ingredient_id: integer | nil,
          ingredient: Ingredient.t() | nil,
          weight: integer,
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "meals" do
    field(:weight, :integer)
    belongs_to(:calendar, Calendar)
    belongs_to(:recipe, Recipe)
    belongs_to(:ingredient, Ingredient)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:weight, :recipe_id, :ingredient_id])
    |> foreign_key_constraint(:recipe_id)
    |> foreign_key_constraint(:ingredient_id)
    |> validate_required([:weight])
    |> unique_constraint(:name, name: :ingredients_name_uniq_idx)
  end
end
