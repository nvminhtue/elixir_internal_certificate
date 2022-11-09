defmodule ElixirInternalCertificateWeb.Api.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  alias ElixirInternalCertificateWeb.Api.ErrorView

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: "unauthorized",
      detail: "Login required"
    })
  end
end
