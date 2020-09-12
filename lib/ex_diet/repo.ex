defmodule ExDiet.Repo do
  use Ecto.Repo, otp_app: :ex_diet, adapter: Ecto.Adapters.Postgres
  import Ecto.Query, only: [from: 2]

  @spec fetch(Ecto.Queryable.t(), integer()) :: Ecto.Queryable.t()
  def fetch(queryable, id) do
    case get(queryable, id) do
      nil -> {:error, :not_found}
      entity -> {:ok, entity}
    end
  end

  @spec fetch_by(Ecto.Queryable.t(), Keyword.t()) :: Ecto.Queryable.t()
  def fetch_by(queryable, opts) do
    case get_by(queryable, opts) do
      nil -> {:error, :not_found}
      entity -> {:ok, entity}
    end
  end

  @spec fetch_first(Ecto.Queryable.t()) :: Ecto.Queryable.t()
  def fetch_first(queryable) do
    case all(from(q in queryable, limit: 1)) do
      [] -> {:error, :not_found}
      [item] -> {:ok, item}
    end
  end
end
