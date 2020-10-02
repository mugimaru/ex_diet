defmodule ExDietWeb.GraphQL.Middleware.RequireAuth do
  @moduledoc false

  @behaviour Absinthe.Middleware

  alias ExDiet.Accounts.User
  alias ExDietWeb.GraphQL.Errors
  alias Absinthe.Resolution

  @spec call(Resolution.t(), term()) :: Resolution.t()

  def call(%Resolution{} = resolution, _) do
    case resolution.context do
      %{user: %User{} = _user} ->
        resolution

      _ ->
        Resolution.put_result(resolution, Errors.authentication_required())
    end
  end
end
