defmodule ElixirInternalCertificate.Scrapper.Schemas.UrlResult do
  use Ecto.Schema

  alias ElixirInternalCertificate.Scrapper.Schemas.SearchResult

  schema "url_results" do
    field :url, :string
    field :type, Ecto.Enum, values: [:ad_word, :non_ad_word]

    belongs_to :search_result, SearchResult

    timestamps()
  end
end
