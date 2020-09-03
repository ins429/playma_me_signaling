# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :playma_me_signaling, PlaymaMeSignalingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "/vqvEdUt24XlmfXSGIrEe1qbDbj9hqGdPcp00tMo1FwriS6/ccWB/VUKb1MgfclU",
  render_errors: [view: PlaymaMeSignalingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: PlaymaMeSignaling.PubSub, adapter: Phoenix.PubSub.PG2]

config :playma_me_signaling, PlaymaMeSignalingWeb.Guardian,
  issuer: "PlaymaMeSignaling",
  secret_key: "secret_garden",
  error_handler: PlaymaMeSignalingWeb.Guardian.ErrorHandler

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
