defmodule ExDietWeb.GraphQL.CalendarTest do
  use ExDiet.DataCase
  use ExDiet.GraphQLCase
  import ExDiet.Factory

  @create_calendar_gql """
  mutation CrCalendar($input: CreateCalendarInput!) {
    createCalendar(input: $input) {
      day
      user { email }
      meals {
        recipe { name }
        ingredient { name }
        weight
      }
    }
  }
  """

  @update_calendar_gql """
  mutation UpCalendar($id: ID!, $input: UpdateCalendarInput!) {
    updateCalendar(input: $input, id: $id) {
      day
      user { email }
      meals {
        recipe { name }
        ingredient { name }
        weight
      }
    }
  }
  """

  setup do
    {:ok, user: insert(:user)}
  end

  describe "`createCalendar` mutation" do
    test "creates calendar with meals", %{user: user} do
      ingredient = insert(:ingredient, user: user)
      recipe = insert(:recipe, user: user)
      insert(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

      params = %{
        day: "2018-01-01",
        meals: [
          %{ingredient_id: global_id(ingredient), weight: 100, position: 0},
          %{recipe_id: global_id(recipe), weight: 42, position: 1}
        ]
      }

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@create_calendar_gql, %{input: params})
        |> graphql_result(:createCalendar)

      assert result[:day] == "2018-01-01"

      assert result[:meals] == [
               %{ingredient: %{name: ingredient.name}, recipe: nil, weight: 100},
               %{recipe: %{name: recipe.name}, ingredient: nil, weight: 42}
             ]
    end
  end

  describe "`updateCalendar` mutation" do
    test "creates calendar with meals", %{user: user} do
      calendar = insert(:calendar, user: user)

      insert(
        :ingredient_meal,
        calendar: calendar,
        ingredient: insert(:ingredient, user: user, name: "foo"),
        weight: 200
      )

      ingredient = insert(:ingredient, user: user, name: "bar")
      recipe = insert(:recipe, name: "baz")
      insert(:recipe_ingredient, recipe: recipe, ingredient: ingredient)

      params = %{
        meals: [
          %{ingredient_id: global_id(ingredient), weight: 100, position: 0},
          %{recipe_id: global_id(recipe), weight: 42, position: 1}
        ]
      }

      result =
        build_conn()
        |> authenticate(user)
        |> graphql_send(@update_calendar_gql, %{input: params, id: global_id(calendar)})
        |> graphql_result(:updateCalendar)

      assert result[:day] == Date.to_string(calendar.day)

      assert result[:meals] == [
               %{ingredient: %{name: ingredient.name}, recipe: nil, weight: 100},
               %{recipe: %{name: recipe.name}, ingredient: nil, weight: 42}
             ]
    end
  end
end
