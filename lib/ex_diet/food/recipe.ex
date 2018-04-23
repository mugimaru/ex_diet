defmodule ExDiet.Food.Recipe do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset

  alias ExDiet.Food.{RecipeIngredient, Ingredient, Meal}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t() | nil,
          user_id: integer | nil,
          user: ExDiet.Accounts.User.t() | nil,
          recipe_ingredients: list(RecipeIngredient),
          weight_cooked: integer | nil,
          eaten: boolean,
          meals: list(Meal.t()),
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "recipes" do
    field(:name, :string)
    field(:description, :string)
    field(:weight_cooked, :integer)
    field(:eaten, :boolean)

    belongs_to(:user, ExDiet.Accounts.User)
    has_many(:meals, Meal)
    has_many(:recipe_ingredients, RecipeIngredient, on_replace: :delete)
    many_to_many(:ingredients, Ingredient, join_through: RecipeIngredient)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :description, :user_id, :weight_cooked, :eaten])
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:recipe_ingredients)
    |> validate_required([:name, :user_id])
    |> validate_number(:weight_cooked, greater_than_or_equal_to: 0)
  end
end
