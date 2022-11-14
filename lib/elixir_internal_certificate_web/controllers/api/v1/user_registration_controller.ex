defmodule ElixirInternalCertificateWeb.Api.V1.UserRegistrationController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Account.Accounts

  def create(conn, params) do
    with {:ok, user} <- Accounts.register_user(params) do
      render(conn, "show.json", %{data: user})
    end
  end
end
