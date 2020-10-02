defmodule ExDiet.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {Phoenix.PubSub, [name: ExDiet.PubSub, adapter: Phoenix.PubSub.PG2]},
      supervisor(ExDiet.Repo, []),
      supervisor(ExDietWeb.Endpoint, [])
    ]

    opts = [strategy: :one_for_one, name: ExDiet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ExDietWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
