defmodule ExDietWeb.GraphQL.Schema do
  @moduledoc false

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  query do
  end

  mutation do
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
