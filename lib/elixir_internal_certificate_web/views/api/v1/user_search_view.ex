defmodule ElixirInternalCertificateWeb.Api.V1.UserSearchView do
  use JSONAPI.View, type: "user_search"

  def fields do
    [
      :keyword,
      :status
    ]
  end
end
