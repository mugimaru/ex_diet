defmodule ExDiet.Accounts.Authentication do
  @moduledoc """
  Authentication helpers
  """

  use Guardian, otp_app: :ex_diet
  require Logger

  alias ExDiet.Repo
  alias ExDiet.Accounts.User
  alias Guardian.DB

  def subject_for_token(%User{} = resource, _claims \\ %{}) do
    {:ok, to_string(resource.id)}
  end

  def resource_from_claims(claims) do
    Repo.fetch(User, claims["sub"])
  end

  def login_user_with_password(email, password) do
    with {:ok, %User{} = user} <- Repo.fetch_by(User, email: to_string(email)),
         {:ok, _} <- User.check_password(user, to_string(password)) do
      {:ok, user}
    else
      e ->
        Logger.debug(fn -> "Unable to login user #{email}: #{inspect(e)}" end)
        {:error, :not_found}
    end
  end

  def login_user_with_token(token, token_type) do
    with {:ok, claims} <- decode_and_verify(token, %{typ: token_type}),
         {:ok, %User{} = user} <- resource_from_claims(claims) do
      {:ok, user}
    else
      e ->
        Logger.debug(fn -> "Unable to login with #{token_type} token #{inspect(token)}: #{inspect(e)}" end)
        {:error, :not_found}
    end
  end

  def logout_user(%User{} = user) do
    user
    |> User.user_tokens("access")
    |> Repo.delete_all()
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
