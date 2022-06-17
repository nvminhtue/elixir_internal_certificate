defmodule ElixirInternalCertificate.Scrapper.Schemas.SearchResult do
  use Ecto.Schema

  schema "search_results" do
    field :top_ad_words_total, :integer
    field :ad_words_total, :integer
    field :non_ad_words_total, :integer
    field :links_total, :integer
    field :preview, :string

    belongs_to :user_search,
               ElixirInternalCertificate.Scrapper.Schemas.UserSearch,
               foreign_key: :user_search_id

    has_many :url_results,
             ElixirInternalCertificate.Scrapper.Schemas.UrlResult,
             foreign_key: :search_result_id

    timestamps()
  end
end
