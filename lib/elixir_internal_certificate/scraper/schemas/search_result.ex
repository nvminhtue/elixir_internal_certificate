defmodule ElixirInternalCertificate.Scraper.Schemas.SearchResult do
  use Ecto.Schema

  import Ecto.Changeset, only: [cast: 3, validate_required: 2, validate_number: 3]

  alias ElixirInternalCertificate.Scraper.Schemas.UserSearch

  schema "search_results" do
    field :top_ad_words_total, :integer
    field :ad_words_total, :integer
    field :non_ad_words_total, :integer
    field :links_total, :integer
    field :html_response, :string
    field :non_ad_words_links, {:array, :string}
    field :top_ad_words_links, {:array, :string}

    belongs_to :user_search,
               UserSearch,
               foreign_key: :user_search_id

    timestamps()
  end

  def create_changeset(search_result, attrs) do
    search_result
    |> cast(attrs, [
      :html_response,
      :user_search_id,
      :ad_words_total,
      :top_ad_words_total,
      :non_ad_words_total,
      :links_total,
      :non_ad_words_links,
      :top_ad_words_links
    ])
    |> validate_required(:html_response)
    |> validate_number(:top_ad_words_total, greater_than_or_equal_to: 0)
    |> validate_number(:non_ad_words_total, greater_than_or_equal_to: 0)
  end
end
