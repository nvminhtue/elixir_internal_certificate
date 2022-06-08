import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :elixir_internal_certificate, ElixirInternalCertificate.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "elixir_internal_certificate_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_internal_certificate, ElixirInternalCertificateWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0zON+zcWlayLkHlyowPOXSGt2GjFDXeKS9P7FSkSbbxUMDtBCi5xID7zrgVy/tob",
  server: true

config :elixir_internal_certificate, :sql_sandbox, true

config :wallaby,
  otp_app: :elixir_internal_certificate,
  chromedriver: [headless: System.get_env("CHROME_HEADLESS", "true") === "true"],
  screenshot_dir: "tmp/wallaby_screenshots",
  screenshot_on_failure: true

# In test we don't send emails.
config :elixir_internal_certificate, ElixirInternalCertificate.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :elixir_internal_certificate, Oban, crontab: false, queues: false, plugins: false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configurations for ExVCR
config :exvcr,
  vcr_cassette_library_dir: "test/support/fixtures/vcr_cassettes",
  ignore_localhost: true
