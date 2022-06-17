defmodule ElixirInternalCertificate.Scrapper.Schemas.UrlResult do
  use Ecto.Schema

  schema "url_results" do
    field :url, :string
    field :type, Ecto.Enum, values: [:ad_word, :non_ad_word]

    belongs_to :search_result,
               ElixirInternalCertificate.Scrapper.Schemas.SearchResult,
               foreign_key: :search_result_id

    timestamps()
  end
end
