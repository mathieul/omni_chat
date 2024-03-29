use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :omni_chat, OmniChat.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :omni_chat, OmniChat.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "omni_chat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Custom configuration
config :omni_chat, :twilio_enabled, false
config :omni_chat, :socket_server, "ws://localhost:4000/socket/websocket"
config :omni_chat, :messaging_service_sid, "MG9c466ba0f4b7900979e845ddea291e91"
config :omni_chat, :domain, "localhost"
