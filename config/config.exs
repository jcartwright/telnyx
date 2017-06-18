# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :telnyx,
  ecto_repos: [Telnyx.Repo]

# Configures the endpoint
config :telnyx, Telnyx.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5tbfThlaIBwJJ9VdDHYIt0+F639lLN6LQQ6hoWJHs5SAw62Jbfu6s+nnO1E3ORpB",
  render_errors: [view: Telnyx.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Telnyx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
