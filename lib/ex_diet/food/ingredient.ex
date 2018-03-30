defmodule ExDiet.Food.Ingredient do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          protein: Decimal.t(),
          fat: Decimal.t(),
          carbonhydrate: Decimal.t(),
          energy: Decimal.t(),
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "ingredients" do
    field(:name, :string)
    field(:protein, :decimal)
    field(:fat, :decimal)
    field(:carbonhydrate, :decimal)
    field(:energy, :decimal)

    timestamps()
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :protein, :fat, :carbonhydrate, :energy])
    |> validate_required([:name, :protein, :fat, :carbonhydrate, :energy])
    |> unique_constraint(:name, name: :ingredients_name_uniq_idx)
  end
end
