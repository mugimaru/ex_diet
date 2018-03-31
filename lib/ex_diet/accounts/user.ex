defmodule ExDiet.Accounts.User do
  @moduledoc "User schema"

  use ExDiet.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__
  alias Comeonin.Bcrypt
  alias ExDiet.Accounts.Authentication
  alias Guardian.DB.Token

  @type t :: %User{
          id: integer,
          email: String.t(),
          password: String.t() | nil,
          password_hash: String.t(),
          ingredients: list(ExDiet.Food.Ingredient),
          inserted_at: %DateTime{},
          updated_at: %DateTime{}
        }

  schema "users" do
    field(:password, :string, virtual: true)
    field(:email, :string)
    field(:password_hash, :string)

    has_many(:ingredients, ExDiet.Food.Ingredient)
    has_many(:recipes, ExDiet.Food.Recipe)

    timestamps()
  end

  def check_password(%User{} = user, password) do
    Bcrypt.check_pass(user, password)
  end

  def user_tokens(%User{} = user) do
    {:ok, sub} = Authentication.subject_for_token(user)
    from(t in Token.query_schema(), where: t.sub == ^sub)
  end

  def user_tokens(%User{} = user, type) when is_list(type) do
    user
    |> user_tokens()
    |> where([t], t.typ in ^type)
  end

  def user_tokens(%User{} = user, type), do: user_tokens(user, [type])

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> unique_constraint(:email, name: :users_email_idx)
    |> put_password_hash()
    |> validate_required([:password_hash])
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: pw}} = changeset) do
    changeset
    |> put_change(:password_hash, Bcrypt.hashpwsalt(pw))
    |> put_change(:password, nil)
  end

  defp put_password_hash(cs), do: cs
end
