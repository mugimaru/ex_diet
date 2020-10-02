defmodule ExDiet.Repo.Migrations.CreateCalendar do
  use Ecto.Migration

  def change do
    create table(:calendar) do
      add :day, :date, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create(index(:calendar, [:user_id, :day], unique: true, name: :calendar_day_uniq_idx))
  end
end
