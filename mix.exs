defmodule ExDiet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_diet,
      version: "1.1.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
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

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:cors_plug, "~> 2.0"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:bcrypt_elixir, "~> 2.0"},
      {:guardian, "~> 2.0"},
      {:guardian_db, "~> 2.0"},
      {:absinthe, "~> 1.5.0"},
      {:absinthe_plug, "~> 1.5.0"},
      {:absinthe_relay, "~> 1.5.0"},
      {:absinthe_phoenix, ">= 2.0.0"},
      {:dataloader, "~> 1.0.0"},
      {:gettext, "~> 0.11"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2", only: :test},
      {:cowboy, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:logger_file_backend, "~> 0.0.11"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.drop --quiet", "ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
