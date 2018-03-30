defmodule ExDiet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_diet,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps_path: System.get_env("DEPS_PATH") || Mix.Project.deps_path(),
      build_path: System.get_env("BUILD_PATH") || Mix.Project.build_path()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExDiet.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.3"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:absinthe, "~> 1.4.9"},
      {:absinthe_plug, "~> 1.4.2"},
      {:absinthe_relay, "~> 1.4.2"},
      {:absinthe_phoenix, ">= 0.0.0"},
      {:dataloader, "~> 1.0.0"},
      {:gettext, "~> 0.11"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:credo, "~> 0.9.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      {:ex_machina, "~> 2.2", only: :test},
      {:excoveralls, "~> 0.8", only: :test},
      {:cowboy, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
