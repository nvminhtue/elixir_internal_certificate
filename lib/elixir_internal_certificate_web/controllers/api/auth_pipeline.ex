defmodule ElixirInternalCertificateWeb.Api.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :elixir_internal_certificate,
    module: ElixirInternalCertificate.Account.Guardian,
    error_handler: ElixirInternalCertificateWeb.Api.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
end
