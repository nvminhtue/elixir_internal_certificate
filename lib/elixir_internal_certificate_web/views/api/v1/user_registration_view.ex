defmodule ElixirInternalCertificateWeb.Api.V1.UserRegistrationView do
  use JSONAPI.View, type: "user_auth"

  def fields do
    [
      :email
    ]
  end
end
