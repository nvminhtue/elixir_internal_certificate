defmodule ElixirInternalCertificateWeb.Api.ErrorView do
  def render("error.json", %{code: code, message: message}),
    do: %{
      errors: [
        %{
          code: code,
          message: message
        }
      ]
    }
end
