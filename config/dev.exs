use Mix.Config

config :ex_diet, ExDietWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :ex_diet, ExDietWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/ex_diet_web/views/.*(ex)$},
      ~r{lib/ex_diet_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :ex_diet, ExDiet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  database: System.get_env("PG_DATABASE") || "ex_diet-dev",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool_size: 10

config :ex_diet_live, ExDietLiveWeb.Endpoint,
  http: [port: 4001],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/ex_diet_live/assets", __DIR__)
    ]
  ]

config :ex_diet_live, ExDietLiveWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ex_diet_live_web/(live|views)/.*(ex)$",
      ~r"lib/ex_diet_live_web/templates/.*(eex)$"
    ]
  ]
