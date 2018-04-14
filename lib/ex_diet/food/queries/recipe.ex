defmodule ExDiet.Food.Queries.Recipe do
  @moduledoc false
  import Ecto.Query

  def search(query, args) do
    Enum.reduce(args, query, fn
      {:filter, filter}, query ->
        from(
          q in query,
          distinct: true,
          left_join: i in assoc(q, :ingredients),
          where: ilike(q.name, ^"%#{filter}%") or ilike(i.name, ^"%#{filter}%")
        )

      {:eaten, eaten}, query ->
        from(q in query, where: q.eaten == ^eaten)

      _, query ->
        query
    end)
  end
end
