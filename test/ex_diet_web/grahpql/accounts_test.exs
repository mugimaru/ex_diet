defmodule ExDietWeb.GraphQL.AccountsTest do
  use ExDiet.DataCase
  use ExDiet.GraphQLCase
  import ExDiet.Factory

  @create_user_gql """
  mutation CreateUser($input: CreateUserInput!) {
    createUser(input: $input) {
      token
      user {
        email
      }
    }
  }
  """

  @login_gql """
  mutation Login($input: LoginUserInput!) {
    login(input: $input) {
      token
      user {
        id
        email
      }
    }
  }
  """

  @logout_gql """
  mutation {
    logout { email }
  }
  """

  @me_gql """
  query {
    me {
      email
      ingredients { name }
    }
  }
  """

  @user_attrs %{email: "foo@bar.com", password: "foobar"}

  describe "`createUser` mutation" do
    test "creates user with access token" do
      result =
        build_conn()
        |> graphql_send(@create_user_gql, input: @user_attrs)
        |> graphql_result(:createUser)

      assert result[:user][:email] == @user_attrs[:email]

      result =
        build_conn()
        |> put_jwt_token(result[:token])
        |> graphql_send("query { me { email } }")
        |> graphql_result(:me)

      assert result[:email] == @user_attrs[:email]
    end

    test "duplicate emails are not allowed" do
      insert(:user, email: @user_attrs[:email])

      result =
        build_conn()
        |> graphql_send(@create_user_gql, input: @user_attrs)
        |> graphql_errors()

      assert [%{fields: %{email: ["has already been taken"]}}] = result
    end
  end

  describe "`logout` mutation" do
    test "deactivates token" do
      user =
        insert(
          :user,
          email: @user_attrs[:email],
          password_hash: Bcrypt.hash_pwd_salt(@user_attrs[:password])
        )

      result =
        build_conn()
        |> graphql_send(@login_gql, input: %{email: user.email, password: @user_attrs[:password]})
        |> graphql_result(:login)

      assert result[:user][:email] == user.email

      build_conn()
      |> put_jwt_token(result[:token])
      |> graphql_send(@logout_gql)

      result =
        build_conn()
        |> put_jwt_token(result[:token])
        |> graphql_send("query { me { email } }")
        |> graphql_errors()

      assert result == [%{code: "not_found", message: "Not authorized"}]
    end
  end

  describe "`login` mutation" do
    test "returns access token" do
      user =
        insert(
          :user,
          email: @user_attrs[:email],
          password_hash: Bcrypt.hash_pwd_salt(@user_attrs[:password])
        )

      result =
        build_conn()
        |> graphql_send(@login_gql, input: %{email: user.email, password: @user_attrs[:password]})
        |> graphql_result(:login)

      assert result[:user][:email] == user.email
    end
  end

  describe "`me` query" do
    test "returns current user with a list of ingredients" do
      ingredient = insert(:ingredient)

      result =
        build_conn()
        |> authenticate(ingredient.user)
        |> graphql_send(@me_gql)
        |> graphql_result(:me)

      assert %{
               email: ingredient.user.email,
               ingredients: [
                 %{name: ingredient.name}
               ]
             } == result
    end
  end
end
