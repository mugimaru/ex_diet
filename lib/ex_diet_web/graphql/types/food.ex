defmodule ExDietWeb.GraphQL.Types.Food do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  connection(node_type: :ingredient)

  node object(:ingredient) do
    field(:name, non_null(:string))
    field(:protein, non_null(:decimal))
    field(:fat, non_null(:decimal))
    field(:carbonhydrate, non_null(:decimal))
    field(:energy, non_null(:decimal))
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end
end
