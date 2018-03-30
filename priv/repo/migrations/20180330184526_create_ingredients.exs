defmodule ExDiet.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :name, :string, null: false
      add :protein, :decimal, null: false, default: 0
      add :fat, :decimal, null: false, default: 0
      add :carbonhydrate, :decimal, null: false, default: 0
      add :energy, :decimal, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create(index(:ingredients, [:name], unique: true, name: :ingredients_name_uniq_idx))
  end
end
