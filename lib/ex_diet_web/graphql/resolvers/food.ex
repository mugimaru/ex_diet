defmodule ExDietWeb.GraphQL.Resolvers.Food do
  @moduledoc false

  alias ExDiet.Repo
  alias ExDiet.Food
  import ExDietWeb.GraphQL.Resolvers.Node, only: [fetch_by_gid: 1]

  def list_ingredients(_parent, args, _resolution) do
    Absinthe.Relay.Connection.from_query(Food.Ingredient, &Repo.all/1, args)
  end

  def create_ingredient(_, %{input: args}, %{context: %{user: user}}) do
    args
    |> Map.put_new(:user_id, user.id)
    |> Food.create_ingredient()
  end

  def update_ingredient(_, %{id: id, input: args}, _) do
    mutate_ingredient(id, &Food.update_ingredient(&1, args))
  end

  def delete_ingredient(_, %{id: id}, _) do
    mutate_ingredient(id, &Food.delete_ingredient/1)
  end

  defp mutate_ingredient(id, fun) do
    with {:ok, %Food.Ingredient{} = ingredient} <- fetch_by_gid(id) do
      fun.(ingredient)
    else
      {:ok, _type} ->
        {:error, :invalid_entity_type}

      any ->
        any
    end
  end
end
