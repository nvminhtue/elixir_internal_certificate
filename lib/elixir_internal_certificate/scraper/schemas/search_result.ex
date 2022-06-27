defmodule ElixirInternalCertificate.Scraper.Schemas.SearchResult do
  use Ecto.Schema

  import Ecto.Changeset, only: [change: 2]

  alias ElixirInternalCertificate.Scraper.Schemas.{UrlResult, UserSearch}

  schema "search_results" do
    field :top_ad_words_total, :integer
    field :ad_words_total, :integer
    field :non_ad_words_total, :integer
    field :links_total, :integer
    field :html_response, :string

    belongs_to :user_search,
               UserSearch,
               foreign_key: :user_search_id

    has_many :url_results,
             UrlResult,
             foreign_key: :search_result_id

    timestamps()
  end

  def search_result_changeset(search_result \\ %__MODULE__{}, attrs),
    do:
      change(search_result, %{
        html_response: attrs.html_response,
        user_search_id: attrs.user_search_id,
        ad_words_total: attrs.ad_words_total,
        top_ad_words_total: attrs.top_ad_words_total,
        non_ad_words_total: attrs.non_ad_words_total,
        links_total: attrs.links_total
      })
end
