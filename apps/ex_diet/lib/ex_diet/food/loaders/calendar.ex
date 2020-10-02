defmodule ExDiet.Food.Loaders.Calendar do
  @moduledoc false
  import Ecto.Query

  def data do
    Dataloader.Ecto.new(ExDiet.Repo, query: &query/2)
  end

  def query(ExDiet.Food.Meal = queryable, _args) do
    from(q in queryable, order_by: q.position)
  end

  def query(queryable, _args) do
    queryable
  end
end
