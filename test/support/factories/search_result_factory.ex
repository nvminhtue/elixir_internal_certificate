defmodule ElixirInternalCertificate.SearchResultFactory do
  @moduledoc """
    This module defines the search_result factory
    using to generate a valid search_result record
  """
  use ExMachina.Ecto, repo: ElixirInternalCertificate.Repo

  alias ElixirInternalCertificate.Scraper.Schemas.SearchResult

  defmacro __using__(_opts) do
    quote do
      def search_result_factory,
        do: %SearchResult{
          top_ad_words_total: Enum.random(0..15),
          ad_words_total: Enum.random(0..15),
          non_ad_words_total: Enum.random(0..15),
          links_total: Enum.random(0..15),
          html_response: "<html></html>",
          non_ad_words_links: [Faker.Internet.url()],
          top_ad_words_links: [Faker.Internet.url()],
          user_search: build(:user_search)
        }
    end
  end
end
