defmodule ExDietWeb.GraphQL.Middlewares.HandleErrors do
  @moduledoc """
  Expand GraphQL errors with `ExDietWeb.GraphQL.Errors`
  """

  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias Ecto.Changeset
  alias ExDietWeb.GraphQL.Errors

  @spec call(Resolution.t(), term()) :: Resolution.t()

  def call(%Resolution{} = resolution, _) do
    %Resolution{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  @spec handle_error(term()) :: list()

  defp handle_error(%Changeset{} = changeset) do
    {:error, result} = Errors.from_changeset(changeset)

    [result]
  end

  defp handle_error(error) when is_atom(error) do
    {:error, result} = Errors.from_code(error)

    [result]
  end

  defp handle_error(error) do
    [error]
  end
end
