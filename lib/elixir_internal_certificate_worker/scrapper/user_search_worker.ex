defmodule ElixirInternalCertificateWorker.Scrapper.UserSearchWorker do
  use Oban.Worker,
    queue: :user_search,
    max_attempts: 3,
    unique: [period: 30]

  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scrapper.{ScrapperEngine, Scrappers}
  alias ElixirInternalCertificateWorker.Scrapper.HtmlParsingHelper

  @max_attempts 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_search_id" => user_search_id}, attempt: @max_attempts}) do
    {:ok, _} = update_user_search(user_search_id, :failed)

    {:error, "max attempts reached, attempt: #{@max_attempts}"}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_search_id" => user_search_id}}) do
    {_, searching_keyword} = update_user_search(user_search_id, :inprogress)

    {:ok, html_response} = ScrapperEngine.get_html(searching_keyword.keyword)

    {:ok, search_result} = HtmlParsingHelper.parsing(html_response)

    Repo.transaction(fn ->
      {:ok, search_result_record} =
        Scrappers.saving_search_result(Map.put(search_result, :user_search_id, user_search_id))

      {:ok} = saving_url_results(search_result, search_result_record.id)

      {:ok, _} = update_user_search(user_search_id, :success)
    end)

    :ok
  end

  defp update_user_search(user_search_id, status),
    do:
      user_search_id
      |> Scrappers.get_user_search()
      |> Scrappers.update_user_search_status(status)

  defp saving_url_results(attrs, search_result_id) do
    non_ad_word_structure =
      Enum.map(
        attrs.non_ad_words_links,
        &structoring_url_result(&1, :non_ad_word, search_result_id)
      )

    ad_word_structure =
      Enum.map(
        attrs.top_ad_words_links,
        &structoring_url_result(&1, :ad_word, search_result_id)
      )

    Scrappers.saving_url(non_ad_word_structure ++ ad_word_structure)

    {:ok}
  end

  defp structoring_url_result([url | _] = _, type, search_result_id) do
    current_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    %{
      url: url,
      type: type,
      search_result_id: search_result_id,
      inserted_at: current_time,
      updated_at: current_time
    }
  end
end
