import Config

config :ex_diet, ExDietWeb.Endpoint,
  http: [
    port: System.get_env("PORT", "4000") |> String.to_integer()
  ],
  url: [
    host: System.get_env("URL_HOST", "localhost"),
    port: System.get_env("URL_PORT", "4000") |> String.to_integer(),
    scheme: System.get_env("URL_SCHEME", "http")
  ],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :ex_diet, ExDiet.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.fetch_env!("POSTGRES_URL")

config :ex_diet_live, ExDietLiveWeb.Endpoint,
  http: [
    port: System.get_env("LV_PORT", "4002") |> String.to_integer()
  ],
  url: [
    host: System.get_env("LV_URL_HOST", "localhost"),
    port: System.get_env("LV_URL_PORT", "4002") |> String.to_integer(),
    scheme: System.get_env("LV_URL_SCHEME", "http")
  ],
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
