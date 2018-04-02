defmodule ExDiet.Food.Ingredient do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset
  alias ExDiet.Food.{RecipeIngredient, Recipe}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          protein: Decimal.t(),
          fat: Decimal.t(),
          carbonhydrate: Decimal.t(),
          energy: Decimal.t(),
          user_id: integer | nil,
          user: ExDiet.Accounts.User.t() | nil,
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "ingredients" do
    field(:name, :string)
    field(:protein, :decimal)
    field(:fat, :decimal)
    field(:carbonhydrate, :decimal)
    field(:energy, :decimal)

    belongs_to(:user, ExDiet.Accounts.User)
    has_many(:recipe_ingredients, RecipeIngredient)
    many_to_many(:recipes, Recipe, join_through: RecipeIngredient)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :protein, :fat, :carbonhydrate, :energy, :user_id])
    |> foreign_key_constraint(:user_id)
    |> validate_number(:protein, greater_than_or_equal_to: 0)
    |> validate_number(:fat, greater_than_or_equal_to: 0)
    |> validate_number(:carbonhydrate, greater_than_or_equal_to: 0)
    |> validate_number(:energy, greater_than_or_equal_to: 0)
    |> validate_required([:name, :protein, :fat, :carbonhydrate, :energy])
    |> unique_constraint(:name, name: :ingredients_name_uniq_idx)
  end
end
