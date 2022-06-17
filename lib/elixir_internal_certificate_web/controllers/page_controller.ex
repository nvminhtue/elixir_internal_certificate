defmodule ElixirInternalCertificateWeb.PageController do
  use ElixirInternalCertificateWeb, :controller

  def index(conn, _params), do: render(conn, "index.html")
end
