defmodule ExDiet.Mixfile do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "1.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        ex_diet: [
          include_executables_for: [:unix],
          applications: [
            runtime_tools: :permanent
          ]
        ]
      ]
    ]
  end

  def application do
    [
      mod: {ExDiet.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    []
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
