defmodule ExDiet.Repo.Migrations.ChangeRecipes do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :weight_cooked, :integer, default: nil
    end

    drop(index(:recipes, [:user_id, :name], name: :recipes_user_id_name_uniq_idx))
  end
end
