defmodule ElixirInternalCertificateWeb.Api.V1.UserAuth do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Account.Accounts
  alias ElixirInternalCertificate.Account.Schemas.User
  alias ElixirInternalCertificateWeb.Api.V1.UserRegistrationView
  alias ElixirInternalCertificateWeb.Api.ErrorView

  def new(conn, params) do
    with changeset <- Accounts.change_user_registration(%User{}, params),
         {:ok, user} <- Accounts.register_user(changeset.changes) do
      conn
      |> put_view(UserRegistrationView)
      |> render("show.json", %{data: user})
    else
      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_view(ErrorView)
        |> put_status(:bad_request)
        |> render("error.json", %{code: :unprocessable_entity, message: "Invalid email or password"})
    end
  end
end
