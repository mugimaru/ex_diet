defmodule ExDiet.Food.Recipe do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset

  alias ExDiet.Food.{RecipeIngredient, Ingredient}

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          description: String.t() | nil,
          user_id: integer | nil,
          user: ExDiet.Accounts.User.t() | nil,
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "recipes" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:user, ExDiet.Accounts.User)
    has_many(:recipe_ingredients, RecipeIngredient, on_replace: :delete)
    many_to_many(:ingredients, Ingredient, join_through: RecipeIngredient)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :description, :user_id])
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:recipe_ingredients)
    |> validate_required([:name, :user_id])
    |> unique_constraint(:name, name: :recipes_user_id_name_uniq_idx)
  end
end
