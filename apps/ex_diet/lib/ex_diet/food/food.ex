defmodule ExDiet.Food do
  @moduledoc """
  The Food context.
  """

  import Ecto.Query, warn: false
  alias ExDiet.Repo

  alias ExDiet.Food.{Recipe, Ingredient, Calendar, Meal}

  def subscribe(struct) do
    Phoenix.PubSub.subscribe(ExDiet.PubSub, topic_for_struct(struct))
  end

  def get_ingredient!(id) do
    Repo.get!(Ingredient, id)
  end

  def change_ingredient(%Ingredient{} = ingredient, params \\ %{}) do
    Ingredient.changeset(ingredient, params)
  end

  def create_ingredient(attrs \\ %{}) do
    %Ingredient{}
    |> Ingredient.changeset(attrs)
    |> Repo.insert()
    |> broadcast_change(:create)
  end

  def update_ingredient(%Ingredient{} = ingredient, attrs) do
    ingredient
    |> Ingredient.changeset(attrs)
    |> Repo.update()
    |> broadcast_change(:update)
  end

  def delete_ingredient(%Ingredient{} = ingredient) do
    case count_references(ingredient) do
      0 ->
        Repo.delete(ingredient)
        |> broadcast_change(:delete)

      _ ->
        {:error, :referenced}
    end
  end

  def create_recipe(attrs \\ %{}) do
    %Recipe{}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
  end

  def update_recipe(%Recipe{} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  def delete_recipe(%Recipe{} = recipe) do
    case count_references(recipe) do
      0 ->
        Repo.delete(recipe)

      _ ->
        {:error, :referenced}
    end
  end

  def create_calendar(attrs) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert()
  end

  def update_calendar(%Calendar{} = calendar, attrs) do
    {:ok, res} =
      Repo.transaction(fn ->
        Repo.delete_all(from(m in Meal, where: m.calendar_id == ^calendar.id))

        calendar
        |> Repo.preload(meals: [:recipe, :ingredient])
        |> Calendar.changeset(attrs)
        |> Repo.update()
      end)

    res
  end

  defp count_references(%Ingredient{} = entity), do: count_references(entity, [:meals, :recipe_ingredients])
  defp count_references(%Recipe{} = entity), do: count_references(entity, [:meals])

  defp count_references(entity, assocs) do
    Enum.reduce(assocs, 0, fn assoc, acc ->
      acc +
        Repo.one(
          from(q in entity.__struct__, join: a in assoc(q, ^assoc), where: q.id == ^entity.id, select: count(a.id))
        )
    end)
  end

  defp broadcast_change({:ok, struct}, event) do
    Phoenix.PubSub.broadcast(ExDiet.PubSub, topic_for_struct(struct.__struct__), {__MODULE__, event, struct})
    {:ok, struct}
  end

  defp broadcast_change(error, _event) do
    error
  end

  defp topic_for_struct(Ingredient), do: "ex_diet:food:ingredients:changes"
  defp topic_for_struct(Recipe), do: "ex_diet:food:recipes:changes"
end
