defmodule ElixirInternalCertificateWeb.Api.V1.UserRegistrationView do
  use JSONAPI.View, type: "user_registration"

  def fields do
    [
      :email
    ]
  end
end
