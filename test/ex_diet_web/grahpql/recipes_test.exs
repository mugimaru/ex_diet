defmodule ExDietWeb.GraphQL.RecipesTest do
  use ExDiet.DataCase
  use ExDiet.GraphQLCase
  import ExDiet.Factory

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

      params = %{
        name: "foo",
        description: "bar",
        recipe_ingredients: [
          %{ingredient_id: global_id(ingredient), weight: 42}
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
      recipe = insert(:recipe, description: "bar")
      ri = insert(:recipe_ingredient, ingredient: ingredient, recipe: recipe)

      new_ingredient = insert(:ingredient)

      params = %{
        name: "foo",
        weight_cooked: 100,
        recipe_ingredients: [
          %{ingredient_id: global_id(new_ingredient), weight: 31},
          %{id: global_id(ri), ingredient_id: global_id(ingredient), weight: ri.weight }
        ]
      }

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@update_recipe_gql, %{id: global_id(recipe), input: params})
        |> graphql_result(:updateRecipe)

      assert %{
               name: "foo",
               description: "bar",
               weight_cooked: 100,
               recipeIngredients: [
                 %{ingredient: %{name: new_ingredient.name}, weight: 31},
                 %{ingredient: %{name: ingredient.name}, weight: ri.weight}
               ]
             } == result
    end
  end

  describe "`deleteRecipe` mutation" do
    test "deletes recipe", %{user: user} do
      recipe = insert(:recipe)

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@delete_recipe_gql, %{id: global_id(recipe)})
        |> graphql_result(:deleteRecipe)

      assert %{name: recipe.name} == result
      assert Repo.get(ExDiet.Food.Recipe, recipe.id) == nil
    end
  end
end
