defmodule ElixirInternalCertificate.Repo do
  use Ecto.Repo,
    otp_app: :elixir_internal_certificate,
    adapter: Ecto.Adapters.Postgres
end
