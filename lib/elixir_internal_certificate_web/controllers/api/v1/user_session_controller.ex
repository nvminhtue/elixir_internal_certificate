defmodule ElixirInternalCertificateWeb.Api.V1.UserSessionController do
  use ElixirInternalCertificateWeb, :controller

  import Plug.Conn

  alias ElixirInternalCertificate.Account.{Accounts, Guardian}
  alias ElixirInternalCertificate.Account.Schemas.User
  alias ElixirInternalCertificateWeb.Api.ErrorView

  def create(conn, %{"email" => email, "password" => password} = _params) do
    with %User{} = user <- Accounts.get_user_by_email_and_password(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user, %{}) do
      render(conn, "show.json", %{
        data: %{id: :os.system_time(:millisecond), token: token, email: user.email}
      })
    else
      nil ->
        conn
        |> put_view(ErrorView)
        |> put_status(:unauthorized)
        |> render("error.json", %{code: :unauthorized, message: "Invalid email or password"})

      _error ->
        conn
        |> put_view(ErrorView)
        |> put_status(:internal_server_error)
        |> render("error.json", %{code: :internal_server_error, message: "Internal server error"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{code: :unprocessable_entity, message: "Invalid email or password"})
  end
end
