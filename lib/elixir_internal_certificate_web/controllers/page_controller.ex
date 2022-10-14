defmodule ElixirInternalCertificateWeb.PageController do
  use ElixirInternalCertificateWeb, :controller

  def index(conn, _params), do: redirect(conn, to: "/keywords")
end
