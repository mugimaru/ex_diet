# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ex_diet, ecto_repos: [ExDiet.Repo]

# Configures the endpoint
config :ex_diet, ExDietWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "m4NcRfxYZzAignPAWdzNap0Ljg6SoStDrfecjXTyVB73+LdHMNS6/I145MiRAXe9",
  render_errors: [view: ExDietWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExDiet.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :guardian, Guardian.DB,
  repo: ExDiet.Repo,
  schema_name: "auth_tokens",
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
