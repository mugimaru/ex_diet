defmodule ExDiet.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :description, :text, null: true, default: nil

      timestamps(type: :utc_datetime)
    end

    create(index(:recipes, [:user_id, :name], unique: true, name: :recipes_user_id_name_uniq_idx))
  end
end
