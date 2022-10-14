defmodule ElixirInternalCertificateWeb.Api.ErrorView do
  def render("error.json", %{code: code, message: message}),
    do: %{code: code, message: message}
end
