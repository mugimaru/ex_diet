defmodule ExDiet.Repo.Migrations.AddUserReferenceToIngredients do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      add(:user_id, references("users", on_delete: :delete_all))
    end
  end
end
