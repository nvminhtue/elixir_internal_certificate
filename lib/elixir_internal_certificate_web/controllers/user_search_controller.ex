defmodule ElixirInternalCertificateWeb.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  # alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes
  alias ElixirInternalCertificateWeb.UserAuth

  def index(conn, _params),
    do:
      conn
      |> UserAuth.require_authenticated_user([])
      |> render("index.html")

  @doc """
  Handle uploaded CSV data
  """
  # def upload(conn, %{"file" => _file}),
  #   do:
  #     conn
  #     |> put_flash(:info, "File uploaded successfully")
  #     |> redirect(to: Routes.user_search_path(conn, :index))
end
