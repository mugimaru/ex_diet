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
        ingredient {
          name
          user { id }
        }
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
      ingredient = insert(:ingredient, user: user)
      recipe = insert(:recipe, description: "bar", user: user)
      ri = insert(:recipe_ingredient, ingredient: ingredient, recipe: recipe)

      new_ingredient = insert(:ingredient, user: user)

      params = %{
        name: "foo",
        weight_cooked: 100,
        recipe_ingredients: [
          %{ingredient_id: global_id(new_ingredient), weight: 31},
          %{id: global_id(ri), ingredient_id: global_id(ingredient), weight: ri.weight},
          %{ingredient: params_for(:ingredient, name: "Created"), weight: 100}
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
                 %{ingredient: %{name: new_ingredient.name, user: %{id: global_id(user)}}, weight: 31},
                 %{ingredient: %{name: ingredient.name, user: %{id: global_id(user)}}, weight: ri.weight},
                 %{ingredient: %{name: "Created", user: %{id: global_id(user)}}, weight: 100}
               ]
             } == result

      {:ok, newIngredient} = ExDiet.Repo.fetch_by(ExDiet.Food.Ingredient, name: new_ingredient.name)
      assert newIngredient.user_id == user.id
    end
  end

  describe "`deleteRecipe` mutation" do
    test "does not allow to delete recipe that linked to calendar", %{user: user} do
      recipe = insert(:recipe, user: user)
      :calendar |> insert(user: user) |> with_recipe(recipe, 200)

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@delete_recipe_gql, %{id: global_id(recipe)})
        |> graphql_errors()

      assert [%{code: "referenced"}] = result
    end

    test "does not allow to delete other user recipe", %{user: user} do
      recipe = insert(:recipe)

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@delete_recipe_gql, %{id: global_id(recipe)})
        |> graphql_errors()

      assert [%{code: "not_found"}] = result
    end

    test "deletes recipe", %{user: user} do
      recipe = insert(:recipe, user: user)

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
