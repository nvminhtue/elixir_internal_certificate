defmodule ElixirInternalCertificate.Repo do
  use Ecto.Repo,
    otp_app: :elixir_internal_certificate,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
