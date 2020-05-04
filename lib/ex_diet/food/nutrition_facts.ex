defmodule ExDiet.Food.NutritionFacts do
  @moduledoc """
  Calculates nutrition facts per 100g of product.

  * `ExDiet.Food.Ingredient`
  * `ExDiet.Food.RecipeIngredient`
  * `ExDiet.Food.Meal`
  * `ExDiet.Food.Calendar`
  """

  @type t :: %__MODULE__{
          protein: Decimal.t(),
          fat: Decimal.t(),
          carbonhydrate: Decimal.t(),
          energy: Decimal.t()
        }

  @nutrients [:protein, :fat, :carbonhydrate, :energy]
  defstruct(Enum.map(@nutrients, &{&1, Decimal.cast(0)}))

  alias ExDiet.Food.{Ingredient, Recipe, RecipeIngredient, Meal, Calendar}
  alias ExDiet.Repo

  def new, do: new(%{})
  def new(%{__struct__: _} = struct), do: new(Map.from_struct(struct))
  def new(list) when is_list(list), do: new(Enum.into(list, %{}))

  def new(map) do
    struct(
      __MODULE__,
      Enum.reduce(@nutrients, map, fn key, map ->
        Map.put(map, key, Decimal.cast(Map.get(map, key, 0)))
      end)
    )
  end

  def calculate(%Ingredient{} = ing), do: new(ing)

  def calculate(%RecipeIngredient{} = ri) do
    @nutrients
    |> Enum.map(&{&1, calculate_one(ri, &1)})
    |> new()
  end

  def calculate(%Meal{} = meal) do
    meal = Repo.preload(meal, [:recipe, :ingredient])

    Enum.reduce(@nutrients, calculate(entity(meal)), fn key, nf ->
      %{nf | key => Decimal.mult(Map.get(nf, key), Decimal.cast(meal.weight / 100))}
    end)
  end

  def calculate(%Calendar{} = calendar) do
    calendar = Repo.preload(calendar, meals: [:recipe, :ingredient])
    sum_nutrition_facts(calendar.meals)
  end

  def calculate(%Recipe{weight_cooked: 0}), do: new()

  def calculate(%Recipe{} = recipe) do
    recipe = Repo.preload(recipe, recipe_ingredients: :ingredient)

    new(
      Enum.reduce(@nutrients, sum_nutrition_facts(recipe.recipe_ingredients), fn key, struct ->
        value =
          struct
          |> Map.get(key)
          |> Decimal.div(Decimal.cast(recipe.weight_cooked))
          |> Decimal.mult(100)

        %{struct | key => value}
      end)
    )
  end

  def calculate_one(%RecipeIngredient{} = ri, key) do
    ri = Repo.preload(ri, :ingredient)

    ri.ingredient
    |> Map.get(key)
    |> Decimal.mult(ri.weight)
    |> Decimal.div(100)
  end

  def calculate_one(struct, key), do: Map.get(calculate(struct), key)

  @spec sum_nutrition_facts(list(t)) :: t
  defp sum_nutrition_facts(list) do
    Enum.reduce(list, new(), fn ri, acc ->
      ri_data = calculate(ri)

      Enum.reduce(@nutrients, acc, fn key, struct ->
        %{struct | key => Decimal.add(Map.get(struct, key), Map.get(ri_data, key))}
      end)
    end)
  end

  defp entity(%Meal{} = meal) do
    cond do
      meal.recipe_id != nil ->
        meal.recipe

      meal.ingredient_id != nil ->
        meal.ingredient

      true ->
        raise ArgumentError
    end
  end
end
