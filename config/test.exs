use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :telnyx, Telnyx.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :telnyx, Telnyx.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "telnyx_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :telnyx, Telnyx.OmegaPricingService,
  endpoint: "http://mock-pricing.com/",
  api_key: "omega-test-key"
