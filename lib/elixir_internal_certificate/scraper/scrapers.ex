defmodule ElixirInternalCertificate.Scraper.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scraper.Schemas.UserSearch

  def insert_search_keywords(attrs),
    do: Repo.insert_all(UserSearch, attrs)

  def create_search_keyword(keywords, user) do
    keywords
    |> parsing_keywords(user)
    |> insert_search_keywords()
    |> elem(0)
  end

  defp parsing_keywords(keywords, user),
    do: Enum.map(keywords, &structuring_user_search(&1, user.id))

  defp structuring_user_search(keyword, user_id) do
    current_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      keyword: keyword,
      user_id: user_id,
      inserted_at: current_time,
      updated_at: current_time
    }
  end
end
