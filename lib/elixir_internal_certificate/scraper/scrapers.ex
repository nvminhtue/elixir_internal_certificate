defmodule ElixirInternalCertificate.Scraper.Scrapers do
  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scraper.Queries.UserSearchQuery
  alias ElixirInternalCertificate.Scraper.Schemas.{SearchResult, UserSearch}
  alias ElixirInternalCertificateWorker.Scraper.JobQueueHelper

  @default_page 1

  def insert_search_keywords(attrs),
    do: Repo.insert_all(UserSearch, attrs, returning: true)

  def create_user_search(keywords, user_id) do
    {keyword_count, uploaded_keywords} =
      keywords
      |> parse_keywords(user_id)
      |> insert_search_keywords()

    JobQueueHelper.enqueue_user_search_worker(uploaded_keywords)

    {keyword_count, uploaded_keywords}
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

  def get_user_search_by_user_id_and_id!(user_id, id)
      when is_integer(id) or is_binary(id) do
    UserSearch
    |> Repo.get_by!(%{user_id: user_id, id: id})
    |> preload_search_results()
  end

  def get_user_search_by_user_id_and_id(user_id, id)
      when is_integer(id) or is_binary(id) do
    UserSearch
    |> Repo.get_by(%{user_id: user_id, id: id})
    |> preload_search_results()
  end

  def get_user_search_by_id(id) when is_integer(id) or is_binary(id) do
    UserSearch
    |> Repo.get_by!(%{id: id})
    |> preload_search_results()
  end

  def get_user_searches(user_id, search_keyword, page \\ @default_page) do
    user_id
    |> UserSearchQuery.fetch_user_search_by_user_id_and_keyword(search_keyword)
    |> Repo.paginate(page: page)
  end

  defp parse_keywords(keywords, user_id),
    do: Enum.map(keywords, &structure_user_search(&1, user_id))

  defp structure_user_search(keyword, user_id) do
    current_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      keyword: keyword,
      user_id: user_id,
      inserted_at: current_time,
      updated_at: current_time
    }
  end

  defp preload_search_results(%UserSearch{} = user_search),
    do: Repo.preload(user_search, :search_results)

  defp preload_search_results(nil),
    do: nil
end
