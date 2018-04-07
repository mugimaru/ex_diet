defmodule ExDiet.Repo.Migrations.AddEatenToRecipes do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add(:eaten, :boolean, null: false, default: false)
    end
  end
end
