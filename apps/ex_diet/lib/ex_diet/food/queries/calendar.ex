defmodule ExDiet.Food.Queries.Calendar do
  @moduledoc false
  import Ecto.Query

  def for_user(query, %ExDiet.Accounts.User{id: id}) do
    from(q in query, where: q.user_id == ^id)
  end

  def search(query, args) do
    Enum.reduce(args, query, fn
      {:filter, filter}, query -> filter(query, filter)
      _, query -> query
    end)
  end

  def filter(query, filter) do
    Enum.reduce(filter, query, fn
      {:created_before, date}, query ->
        from(q in query, where: q.created_at <= ^date)

      {:created_after, date}, query ->
        from(q in query, where: q.created_at >= ^date)

      {:before, date}, query ->
        from(q in query, where: q.day <= ^date)

      {:after, date}, query ->
        from(q in query, where: q.day >= ^date)
    end)
  end
end
