defmodule ExDiet.GraphQLCase do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest

      @endpoint ExDietWeb.Endpoint

      @spec graphql_send(Plug.Conn.t(), String.t(), map()) :: Plug.Conn.t()
      def graphql_send(conn, query, variables \\ %{}) do
        post(conn, "/api/graphql", %{query: query, variables: variables})
      end

      @spec graphql_result(conn :: Plug.Conn.t(), key :: String.t()) :: any()
      def graphql_result(conn, key) do
        result = body_json(conn)

        case Map.has_key?(result, :data) do
          true ->
            result
            |> Map.get(:data, %{})
            |> Map.get(key)

          false ->
            result
            |> Map.get(:errors, [])
            |> List.first()
        end
      end

      @spec graphql_errors(Plug.Conn.t()) :: any()
      def graphql_errors(conn) do
        body_json(conn)[:errors]
      end

      @spec graphql_unpack_connection(%{edges: map}) :: map
      def graphql_unpack_connection(%{edges: result}), do: graphql_unpack_connection(result)
      @spec graphql_unpack_connection(map) :: map
      def graphql_unpack_connection(result), do: Enum.map(result, & &1[:node])

      @spec body_json(Plug.Conn.t()) :: map()
      def body_json(conn) do
        Jason.decode!(conn.resp_body, %{keys: :atoms})
      end

      def authenticate(conn, %ExDiet.Accounts.User{} = user, opts \\ []) do
        {:ok, token, _claims} = ExDiet.Accounts.Authentication.encode_and_sign(user, %{"typ" => "access"}, opts)
        put_jwt_token(conn, token)
      end

      def put_jwt_token(conn, token) do
        conn
        |> put_req_header("authorization", "Bearer " <> token)
      end

      def global_id(%ExDiet.Food.Calendar{id: id}), do: Absinthe.Relay.Node.to_global_id("Calendar", id)
      def global_id(%ExDiet.Food.Recipe{id: id}), do: Absinthe.Relay.Node.to_global_id("Recipe", id)
      def global_id(%ExDiet.Food.Ingredient{id: id}), do: Absinthe.Relay.Node.to_global_id("Ingredient", id)
      def global_id(%ExDiet.Food.RecipeIngredient{id: id}), do: Absinthe.Relay.Node.to_global_id("RecipeIngredient", id)
      def global_id(%ExDiet.Accounts.User{id: id}), do: Absinthe.Relay.Node.to_global_id("User", id)
    end
  end
end
