defmodule ExDietWeb.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias ExDietWeb.GraphQL

  import_types(Absinthe.Type.Custom)
  import_types(Absinthe.Phoenix.Types)

  import_types(GraphQL.Types.Food)
  import_types(GraphQL.Queries.Food)
  import_types(GraphQL.Mutations.Food)

  node interface do
    resolve_type(&GraphQL.Resolvers.Node.resolve_struct_to_absinthe_type/2)
  end

  query do
    node field do
      resolve(&GraphQL.Resolvers.Node.get/2)
    end

    import_fields(:food_queries)
  end

  mutation do
    import_fields(:food_mutations)
  end

  def middleware(middleware, _field, _config) do
    middleware ++ [GraphQL.Middlewares.HandleErrors]
  end

  def plugins do
    [Absinthe.Middleware.Dataloader]
  end

  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  def dataloader do
    Dataloader.new()
  end
end
