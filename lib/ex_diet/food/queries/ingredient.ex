defmodule ExDiet.Food.Queries.Ingredient do
  @moduledoc false
  import Ecto.Query

  def global(query) do
    from q in query, where: is_nil(q.user_id)
  end

  def for_user_or_global(query, %ExDiet.Accounts.User{id: id}) do
    from q in query, where: is_nil(q.user_id) or q.user_id == ^id
  end
end
