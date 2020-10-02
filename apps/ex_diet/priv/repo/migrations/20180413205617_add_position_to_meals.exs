defmodule ExDiet.Repo.Migrations.AddPositionToMeals do
  use Ecto.Migration

  def change do
    alter table(:meals) do
      add(:position, :integer, null: false, default: 0)
    end

    execute("DELETE from calendar")
    create(index(:meals, [:calendar_id, :position], unique: true, name: :meals_position_uniq_idx))
  end
end
