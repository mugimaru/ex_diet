defmodule ExDietWeb.GraphQL.Plug.TokenAuth do
  @moduledoc """
  Absinthe token authentication plug
  """

  @behaviour Plug

  import Plug.Conn

  alias ExDiet.Accounts.User
  alias ExDiet.Accounts.Authentication
  alias ExDietWeb.ErrorView

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      {:error, reason} ->
        conn
        |> put_status(401)
        |> Phoenix.Controller.render(ErrorView, "401.json", %{reason: reason})
        |> halt()

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %User{} = user} <- Authentication.login_user_with_token(token, "access") do
      {:ok, %{user: user}}
    end
  end
end
