defmodule ElixirInternalCertificateWeb.Api.V1.KeywordUploadView do
  use JSONAPI.View, type: "keyword_upload"

  def fields do
    [
      :keyword
    ]
  end
end
