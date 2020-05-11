defmodule ExDiet.Food.Queries.Ingredient do
  @moduledoc false
  import Ecto.Query

  def global(query) do
    from(q in query, where: is_nil(q.user_id))
  end

  def recent_first(query) do
    from(q in query, order_by: [desc: q.updated_at])
  end

  def most_used_first(query) do
    from(q in query,
      order_by: [
        desc: fragment(~S[SELECT count(ri.id) FROM "recipe_ingredients" AS ri WHERE (ri."ingredient_id" = ?)], q.id)
      ]
    )
  end

  def search(query, %{filter: filter}) when not is_nil(filter) do
    from(q in query, where: ilike(q.name, ^"%#{filter}%"))
  end

  def search(query, _), do: query

  def for_user_or_global(query, %ExDiet.Accounts.User{id: id}) do
    from(q in query, where: is_nil(q.user_id) or q.user_id == ^id)
  end
end
