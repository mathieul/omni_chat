# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :omni_chat,
  ecto_repos: [OmniChat.Repo]

# Configures the endpoint
config :omni_chat, OmniChat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z+6UIBQWVCJb5/bgJvHn7GkTt9vYeXvXIbTGV1FcNoJi+RLXGcbiOg7i2dqJJ+4o",
  render_errors: [view: OmniChat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OmniChat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Twilio
config :ex_twilio, account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
                   auth_token:  System.get_env("TWILIO_AUTH_TOKEN")

config :omni_chat, calling_number: "+15103610074"

# JSON API
config :phoenix, :format_encoders,
  "json-api": Poison

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

# config :ja_serializer,
#   key_format: :underscored


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
