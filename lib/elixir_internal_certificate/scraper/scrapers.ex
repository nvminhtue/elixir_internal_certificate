defmodule ElixirInternalCertificate.Scraper.Scrapers do
  @moduledoc """
  The Scrapers context.
  """
  import Ecto.Query

  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scraper.Schemas.{SearchResult, UserSearch}
  alias ElixirInternalCertificateWorker.Scraper.JobQueueHelper

  @default_page 1
  @default_page_size 10

  def insert_search_keywords(attrs),
    do: Repo.insert_all(UserSearch, attrs, returning: true)

  def create_user_search(keywords, user) do
    {keyword_count, uploaded_keywords} =
      keywords
      |> parse_keywords(user)
      |> insert_search_keywords()

    JobQueueHelper.enqueue_user_search_worker(uploaded_keywords)

    keyword_count
  end

  def get_user_search(id) when is_integer(id) or is_binary(id) do
    UserSearch
    |> Repo.get(id)
    |> Repo.preload(:search_results)
  end

  def get_user_searches(user_id, page \\ @default_page, page_size \\ @default_page_size) when is_integer(user_id) do
    UserSearch
    |> where([u], u.user_id == ^user_id)
    |> order_by(asc: :id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def update_user_search_status(user_search, status) do
    user_search
    |> UserSearch.status_changeset(status)
    |> Repo.update()
  end

  def save_search_result(result) do
    %SearchResult{}
    |> SearchResult.create_changeset(result)
    |> Repo.insert(returning: true)
  end

  defp parse_keywords(keywords, user),
    do: Enum.map(keywords, &structure_user_search(&1, user.id))

  defp structure_user_search(keyword, user_id) do
    current_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      keyword: keyword,
      user_id: user_id,
      inserted_at: current_time,
      updated_at: current_time
    }
  end
end
