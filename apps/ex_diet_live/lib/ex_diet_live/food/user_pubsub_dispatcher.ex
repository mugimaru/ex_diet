defmodule ExDietLive.Food.UserPubSubDispatcher do
  @moduledoc "Dispatches `ExDiet.Food` events into separate topics for each user."

  use GenServer
  alias ExDiet.Food
  alias ExDiet.Food.{Recipe, Ingredient}

  @structs [Ingredient, Recipe]

  @spec subscribe(ExDiet.Accounts.User.t(), Ingredient | Recipe) :: :ok | {:error, term}
  def subscribe(%ExDiet.Accounts.User{id: user_id}, struct) when struct in @structs do
    Phoenix.PubSub.subscribe(ExDietLive.PubSub, topic(struct, user_id))
  end

  def start_link(_) do
    GenServer.start(__MODULE__, nil, name: {:global, __MODULE__})
  end

  def init(_) do
    for struct <- @structs do
      :ok = ExDiet.Food.subscribe(struct)
    end

    {:ok, nil}
  end

  def handle_info({Food, event, struct}, st) do
    Phoenix.PubSub.broadcast!(ExDietLive.PubSub, topic(struct.__struct__, struct.user_id), {Food, event, struct})
    {:noreply, st}
  end

  defp topic(Ingredient, user_id), do: "ex_diet:food:ingredients:#{user_id}:changes"
  defp topic(Recipe, user_id), do: "ex_diet:food:recipes:#{user_id}:changes"
end
