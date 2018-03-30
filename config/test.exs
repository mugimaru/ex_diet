use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_diet, ExDietWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ex_diet, ExDiet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PG_USER") || "postgres",
  password: System.get_env("PG_PASSWORD") || "postgres",
  database: System.get_env("PG_DATABASE") || "ex_diet-test",
  hostname: System.get_env("PG_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
