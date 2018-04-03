defmodule ExDiet.Food.Queries.Recipe do
  @moduledoc false
  import Ecto.Query

  def search(query, %{filter: filter}) when not is_nil(filter) do
    from q in query,
      left_join: i in assoc(q, :ingredients),
      where: ilike(q.name, ^"%#{filter}%") or ilike(i.name, ^"%#{filter}%")
  end
  def search(query, _), do: query
end
