defmodule ExDiet.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ExDiet.Repo

  alias ExDiet.Accounts.{User, Authentication}

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def login_with_password(email, password) do
    Authentication.login_user_with_password(email, password)
  end

  def login_with_token(token, token_type) do
    Authentication.login_user_with_token(token, token_type)
  end

  def logout(u), do: Authentication.logout_user(u)
end
