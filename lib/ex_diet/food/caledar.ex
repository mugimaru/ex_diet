defmodule ExDiet.Food.Calendar do
  @moduledoc false

  use ExDiet.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          day: Date.t(),
          user_id: integer,
          user: ExDiet.Accounts.User.t(),
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "calendar" do
    field(:day, :date)

    belongs_to(:user, ExDiet.Accounts.User)
    timestamps()
  end

  @doc false
  def changeset(calendar, attrs) do
    calendar
    |> cast(attrs, [:day, :user_id])
    |> validate_required([:day])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:day, name: :calendar_day_uniq_idx)
  end
end
