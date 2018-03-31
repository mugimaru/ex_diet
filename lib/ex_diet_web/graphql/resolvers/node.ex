defmodule ExDietWeb.GraphQL.Resolvers.Node do
  @moduledoc false

  alias ExDietWeb.GraphQL.Schema
  alias Absinthe.Relay

  @absinthe_type_to_module_map [
    ingredient: ExDiet.Food.Ingredient,
    recipe: ExDiet.Food.Recipe,
    recipe_ingredient: ExDiet.Food.RecipeIngredient
  ]

  def fetch_by_gid(gid) do
    with {:ok, params} <- Relay.Node.from_global_id(gid, Schema) do
      get(params, nil)
    end
  end

  @spec get(%{type: atom(), id: integer()}, term) :: {:ok, struct()} | {:error, :not_found}
  def get(%{type: type, id: local_id}, _) do
    with {:ok, module} <- absinthe_type_to_module(type) do
      ExDiet.Repo.fetch(module, local_id)
    end
  end

  @spec get(%{id: integer()}, term) :: {:ok, struct()} | {:error, :invalid_id}
  def get(%{id: _}, _), do: {:error, :invalid_id}

  @spec resolve_struct_to_absinthe_type(struct(), term) :: atom | {:error, :not_found}
  def resolve_struct_to_absinthe_type(struct, _) do
    with {:ok, atom} <- struct_to_absinthe_type(struct) do
      atom
    end
  end

  @absinthe_type_to_module_map
  |> Enum.each(fn {absinthe_type, module} ->
    defp struct_to_absinthe_type(%{__struct__: unquote(module)}) do
      {:ok, unquote(absinthe_type)}
    end

    defp absinthe_type_to_module(unquote(absinthe_type)) do
      {:ok, unquote(module)}
    end
  end)

  defp struct_to_absinthe_type(_), do: {:error, :not_found}
  defp absinthe_type_to_module(_), do: {:error, :not_found}
end
