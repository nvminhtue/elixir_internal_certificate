defmodule ElixirInternalCertificate.Repo do
  use Ecto.Repo,
    otp_app: :elixir_internal_certificate,
    adapter: Ecto.Adapters.Postgres
<<<<<<< HEAD

=======
>>>>>>> 63ec287 ([#14] Implement backend of showing scraping keywords)
  use Scrivener, page_size: 10
end
