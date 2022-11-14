defmodule ElixirInternalCertificateWeb.Api.V1.SearchResultView do
  use JSONAPI.View, type: "search_result"

  def fields do
    [
      :top_ad_words_total,
      :ad_words_total,
      :non_ad_words_total,
      :links_total,
      :html_response,
      :non_ad_words_links,
      :top_ad_words_links
    ]
  end
end
