defmodule ExDiet.Repo.Migrations.CreateMeals do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add(:calendar_id, references(:calendar, on_delete: :delete_all), null: false)
      add(:ingredient_id, references(:ingredients, on_delete: :delete_all))
      add(:recipe_id, references(:recipes, on_delete: :delete_all))
      add(:weight, :integer, null: false, default: 0)

      timestamps(type: :utc_datetime)
    end

    create(
      constraint(
        :meals,
        :must_have_one_eatable_reference,
        check: "(ingredient_id IS NULL AND recipe_id IS NOT NULL) OR (recipe_id IS NULL AND ingredient_id IS NOT NULL)"
      )
    )
  end
end
