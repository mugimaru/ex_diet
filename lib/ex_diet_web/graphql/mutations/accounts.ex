defmodule ExDietWeb.GraphQL.Mutations.Accounts do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias ExDietWeb.GraphQL.Resolvers.Accounts, as: Resolver
  alias ExDietWeb.GraphQL.Middleware.RequireAuth

  input_object :login_user_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end

  input_object :create_user_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end

  object :accounts_mutations do
    field :login, type: :session do
      arg(:input, non_null(:login_user_input))

      resolve(&Resolver.login/3)
    end

    field :logout, type: :user do
      middleware(RequireAuth)
      resolve(&Resolver.logout/3)
    end

    field :create_user, type: :session do
      arg(:input, non_null(:create_user_input))

      resolve(&Resolver.create_user/3)
    end
  end
end
