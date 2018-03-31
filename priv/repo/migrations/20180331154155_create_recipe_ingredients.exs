defmodule ExDiet.Repo.Migrations.CreateRecipeIngredients do
  use Ecto.Migration

  def change do
    create table(:recipe_ingredients) do
      add :ingredient_id, references(:ingredients, on_delete: :delete_all), null: false
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false
      add :weight, :integer, null: false
    end

    create(index(:recipe_ingredients, [:ingredient_id, :recipe_id], unique: true, name: :recipe_ingredients_uniq_idx))
  end
end
