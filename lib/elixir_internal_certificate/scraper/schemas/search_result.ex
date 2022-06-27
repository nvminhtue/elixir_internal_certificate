defmodule ElixirInternalCertificate.Scraper.Schemas.SearchResult do
  use Ecto.Schema

  schema "search_results" do
    field :top_ad_words_total, :integer
    field :ad_words_total, :integer
    field :non_ad_words_total, :integer
    field :links_total, :integer
    field :html_response, :string

    belongs_to :user_search,
               ElixirInternalCertificate.Scraper.Schemas.UserSearch,
               foreign_key: :user_search_id

    has_many :url_results,
             ElixirInternalCertificate.Scraper.Schemas.UrlResult,
             foreign_key: :search_result_id

    timestamps()
  end
end
