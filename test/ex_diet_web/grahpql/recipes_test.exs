defmodule ExDietWeb.GraphQL.RecipesTest do
  use ExDiet.DataCase
  use ExDiet.GraphQLCase
  import ExDiet.Factory

  alias Absinthe.Relay.Node

  @create_recipe_gql """
  mutation CrRecipe($input: CreateRecipeInput!) {
    createRecipe(input: $input) {
      name
      description
      weight_cooked
      recipeIngredients {
        ingredient {
          name
        }
        weight
      }
    }
  }
  """

  @update_recipe_gql """
  mutation UpRecipe($id: ID!, $input: UpdateRecipeInput!) {
    updateRecipe(input: $input, id: $id) {
      name
      description
      weight_cooked
      recipeIngredients {
        ingredient { name }
        weight
      }
    }
  }
  """

  @delete_recipe_gql """
  mutation DelRecipe($id: ID!) {
    deleteRecipe(id: $id) { name }
  }
  """

  setup do
    {:ok, user: insert(:user)}
  end

  describe "`createRecipe` mutation" do
    test "creates recipe with ingredients", %{user: user} do
      ingredient = insert(:ingredient)
      ingredient_gid = Node.to_global_id("Ingredient", ingredient.id)

      params = %{
        name: "foo",
        description: "bar",
        recipe_ingredients: [
          %{ingredient_id: ingredient_gid, weight: 42}
        ]
      }

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@create_recipe_gql, %{input: params})
        |> graphql_result(:createRecipe)

      assert %{
               name: params[:name],
               weight_cooked: nil,
               description: params[:description],
               recipeIngredients: [
                 %{ingredient: %{name: ingredient.name}, weight: 42}
               ]
             } == result
    end
  end

  describe "`updateRecipe` mutation" do
    test "updates recipe with an ability to add ingredient", %{user: user} do
      ingredient = insert(:ingredient)
      recipe = :recipe |> insert(description: "bar") |> with_ingredient(ingredient, 42)
      recipe_gid = Node.to_global_id("Recipe", recipe.id)

      new_ingredient = insert(:ingredient)
      ingredient_gid = Node.to_global_id("Ingredient", new_ingredient.id)

      params = %{
        name: "foo",
        weight_cooked: 100,
        recipe_ingredients: [
          %{ingredient_id: ingredient_gid, weight: 31}
        ]
      }

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@update_recipe_gql, %{id: recipe_gid, input: params})
        |> graphql_result(:updateRecipe)

      assert %{
               name: "foo",
               description: "bar",
               weight_cooked: 100,
               recipeIngredients: [
                 %{ingredient: %{name: new_ingredient.name}, weight: 31},
                 %{ingredient: %{name: ingredient.name}, weight: 42}
               ]
             } == result
    end
  end

  describe "`deleteRecipe` mutation" do
    test "deletes recipe", %{user: user} do
      recipe = insert(:recipe)
      recipe_gid = Node.to_global_id("Recipe", recipe.id)

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@delete_recipe_gql, %{id: recipe_gid})
        |> graphql_result(:deleteRecipe)

      assert %{name: recipe.name} == result
      assert Repo.get(ExDiet.Food.Recipe, recipe.id) == nil
    end
  end
end
