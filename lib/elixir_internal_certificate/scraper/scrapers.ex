defmodule ElixirInternalCertificate.Scraper.Scrapers do
  @moduledoc """
  The Scrapers context.
  """

  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scrapper.Schemas.{SearchResult, UrlResult, UserSearch}

  def insert_search_keywords(attrs),
    do: Repo.insert_all(UserSearch, attrs, returning: true)

  def create_user_search(keywords, user) do
    keywords
    |> parsing_keywords(user)
    |> insert_search_keywords()
  end

  def get_user_search(id), do: Repo.get(UserSearch, id)

  def update_user_search_status(user_search, status) do
    user_search
    |> UserSearch.status_changeset(status)
    |> Repo.update()
  end

  def saving_search_result(result) do
    %SearchResult{}
    |> SearchResult.search_result_changeset(result)
    |> Repo.insert(returning: true)
  end

  def saving_url(result),
    do: Repo.insert_all(UrlResult, result)

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
