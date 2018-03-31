defmodule ExDietWeb.GraphQL.Types.Accounts do
  @moduledoc false

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers, only: [dataloader: 2]

  node object(:user) do
    field(:email, non_null(:string))
    field(:inserted_at, :datetime)
    field(:updated_at, :datetime)
  end

  object(:session) do
    field(:user, non_null(:user))
    field(:token, non_null(:string))
  end
end
