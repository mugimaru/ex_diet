defmodule ExDiet.Food.Loaders.Meal do
  @moduledoc false

  import Ecto.Query

  def data do
    Dataloader.Ecto.new(ExDiet.Repo, query: &query/2)
  end

  def query(ExDiet.Food.Recipe = queryable, _args) do
    from(q in queryable, preload: [recipe_ingredients: [:ingredient]])
  end

  def query(queryable, _args) do
    queryable
  end
end
