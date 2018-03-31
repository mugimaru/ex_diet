defmodule ExDietWeb.GraphQL.Errors do
  @moduledoc """
  GraphQL errors descriptions.
  """

  import ExDietWeb.Gettext
  alias Ecto.Changeset

  @type error :: %{
          message: String.t(),
          code: String.t(),
          fields: changeset_errors | []
        }

  @type changeset_errors :: %{
          optional(atom) => list(String.t())
        }

  @spec from_code(atom) :: {:error, map}

  def from_code(:not_found), do: not_found()
  def from_code(:invalid_credentials), do: invalid_credentials()

  @spec not_found() :: {:error, map}

  def not_found do
    {:error, %{message: dgettext("errors", "resource not found"), code: "not_found"}}
  end

  @spec authentication_required() :: {:error, map}

  def authentication_required do
    {:error, %{message: dgettext("errors", "authentication required"), code: "authentication_required"}}
  end

  def invalid_credentials do
    {:error, %{message: dgettext("errors", "invalid credentials"), code: "invalid_credentials"}}
  end

  @spec from_changeset(Changeset.t()) :: {:error, error}

  def from_changeset(%Changeset{} = changeset) do
    changeset
    |> changeset_errors()
    |> validation_error()
  end

  @spec validation_error(map) :: {:error, map}

  defp validation_error(fields) do
    {:error,
     %{
       message: dgettext("errors", "validation error"),
       code: "validation_error",
       fields: fields
     }}
  end

  @spec changeset_errors(changeset :: Changeset.t()) :: changeset_errors

  defp changeset_errors(%Changeset{} = changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Gettext.dgettext(ExDietWeb.Gettext, "errors", msg, opts)
    end)
  end
end
