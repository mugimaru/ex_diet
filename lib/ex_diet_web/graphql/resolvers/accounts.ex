defmodule ExDietWeb.GraphQL.Resolvers.Accounts do
  @moduledoc false

  require Logger

  alias ExDiet.Accounts
  alias ExDiet.Accounts.{User, Authentication}

  def login(_, %{input: %{email: email, password: password}}, _) do
    with {:ok, user} <- Accounts.login_with_password(email, password),
         {:ok, token, _} <- Authentication.encode_and_sign(user) do
      {:ok, %{user: user, token: token}}
    else
      error ->
        Logger.debug(fn -> "Unable to login user #{inspect(error)}" end)
        {:error, :invalid_credentials}
    end
  end

  def logout(_, _, %{context: %{user: %User{} = user}}) do
    Accounts.logout(user)
  end

  def create_user(_, %{input: attrs}, _) do
    with {:ok, user} <- Accounts.create_user(attrs),
         {:ok, token, _} <- Authentication.encode_and_sign(user) do
      {:ok, %{user: user, token: token}}
    end
  end
end
