defmodule ExDietWeb.GraphQL.IngredientsTest do
  use ExDiet.DataCase
  use ExDiet.GraphQLCase
  import ExDiet.Factory

  @create_query """
  mutation M($input: CreateIngredientInput!) {
    createIngredient(input: $input) { id name protein fat carbonhydrate energy user { email } }
  }
  """

  @delete_query """
  mutation M($id: ID!){
    deleteIngredient(id: $id) { id }
  }
  """

  @update_query """
  mutation M($input: UpdateIngredientInput!, $id: ID!) {
    updateIngredient(input: $input, id: $id) { id name protein fat carbonhydrate energy }
  }
  """

  @list_query """
  query {
    listIngredients(first: 10) {
      edges {
        node { id }
      }
    }
  }
  """

  test "an ability to create, update, read and delete ingredients" do
    user = insert(:user)
    # create
    params = params_for(:ingredient, protein: 1, fat: 2, carbonhydrate: 3, energy: 4, name: "foobar")
    conn = build_conn() |> authenticate(user)

    result = conn |> graphql_send(@create_query, %{input: params}) |> graphql_result(:createIngredient)

    assert %{
             id: id,
             protein: "1",
             fat: "2",
             carbonhydrate: "3",
             energy: "4",
             name: "foobar"
           } = result

    assert result[:user][:email] == user.email

    # update
    conn = conn |> graphql_send(@update_query, input: %{fat: 42}, id: id)
    result = conn |> graphql_result(:updateIngredient)

    assert result[:fat] == "42"

    # list
    conn = conn |> graphql_send(@list_query)
    result = conn |> graphql_result(:listIngredients) |> graphql_unpack_connection()
    assert result == [%{id: id}]

    # delete
    conn = build_conn() |> authenticate(user) |> graphql_send(@delete_query, id: id)
    result = conn |> graphql_result(:deleteIngredient)
    assert result == %{id: id}

    # ensure deleted
    conn = conn |> graphql_send(@list_query)
    result = conn |> graphql_result(:listIngredients) |> graphql_unpack_connection()
    assert result == []
  end

  test "duplicate ingredients are not allowed" do
    insert(:ingredient, name: "foo")

    result =
      build_conn()
      |> authenticate(insert(:user))
      |> graphql_send(@create_query, input: params_for(:ingredient, name: "foo"))
      |> graphql_errors()

    assert [error] = result
    assert error[:code] == "validation_error"
    assert error[:fields] == %{name: ["has already been taken"]}
  end
end
