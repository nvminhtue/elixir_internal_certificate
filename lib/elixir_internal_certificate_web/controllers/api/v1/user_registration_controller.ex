defmodule ElixirInternalCertificateWeb.Api.V1.UserRegistrationController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Account.Accounts
  alias ElixirInternalCertificate.Account.Schemas.User

  def create(conn, params) do
    with %{changes: validated_params} = _changeset <- Accounts.change_user_registration(%User{}, params),
         {:ok, user} <- Accounts.register_user(validated_params) do
      render(conn, "show.json", %{data: user})
    else
      error ->
        error
    end
  end
end
