use Mix.Config

config :logger, :console,
  format: "$dateT$time [$level] $levelpad$metadata$message\n",
  metadata: [:request_id],
  level: :info

config :ex_diet, ExDietWeb.Endpoint, server: true
config :ex_diet_live, ExDietLiveWeb.Endpoint, server: true
