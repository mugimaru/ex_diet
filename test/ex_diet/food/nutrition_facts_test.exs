defmodule ExDiet.Food.NutritionFactsTest do
  use ExDiet.DataCase
  import ExDiet.Factory

  alias ExDiet.Food.NutritionFacts, as: NF

  test "calculates nutrition facts for ingredient" do
    ingredient = insert(:ingredient, protein: 10, fat: 20, carbonhydrate: 30, energy: 100)

    assert NF.calculate(ingredient) == %NF{
             protein: Decimal.new(10),
             fat: Decimal.new(20),
             carbonhydrate: Decimal.new(30),
             energy: Decimal.new(100)
           }
  end

  test "calculates nutrition facts for recipe ingredient" do
    ingredient = insert(:ingredient, protein: 10, fat: 20, carbonhydrate: 30, energy: 100)
    recipe = insert(:recipe)
    ri = insert(:recipe_ingredient, ingredient: ingredient, recipe: recipe, weight: 150)

    assert NF.calculate(ri) == %NF{
             protein: Decimal.new(15),
             fat: Decimal.new(30),
             carbonhydrate: Decimal.new(45),
             energy: Decimal.new(150)
           }
  end

  test "calculates nutrition facts for recipe" do
    ingredient = insert(:ingredient, protein: 10, fat: 20, carbonhydrate: 30, energy: 100)
    ingredient2 = insert(:ingredient, protein: 5, fat: 10, carbonhydrate: 50, energy: 1000)

    recipe =
      :recipe
      |> insert(weight_cooked: 200)
      |> with_ingredient(ingredient, 200)
      |> with_ingredient(ingredient2, 100)

    assert NF.calculate(recipe) == %NF{
             protein: Decimal.new(25 * 3 / 2),
             fat: Decimal.new(50 * 3 / 2),
             carbonhydrate: Decimal.new(110 * 3 / 2),
             energy: Decimal.mult(Decimal.new(1200), Decimal.new(3 / 2))
           }
  end

  test "calculates nutrition facts for calendar" do
    calendar = insert(:calendar)

    ingredient = insert(:ingredient, protein: 10, fat: 20, carbonhydrate: 30, energy: 100)
    ingredient2 = insert(:ingredient, protein: 5, fat: 10, carbonhydrate: 50, energy: 1000)

    recipe =
      :recipe
      |> insert(weight_cooked: 200)
      |> with_ingredient(ingredient, 200)
      |> with_ingredient(ingredient2, 100)

    insert(:recipe_meal, recipe: recipe, calendar: calendar, weight: 100)
    insert(:ingredient_meal, ingredient: ingredient, calendar: calendar, weight: 200)

    result = NF.calculate(calendar)
    assert Decimal.to_float(result.protein) == 57.5
    assert Decimal.to_float(result.fat) == 115
    assert Decimal.to_float(result.carbonhydrate) == 225
    assert Decimal.to_float(result.energy) == 2000
  end
end
