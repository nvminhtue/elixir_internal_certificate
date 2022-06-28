defmodule ElixirInternalCertificateWorker.Scraper.UserSearchWorker do
  use Oban.Worker,
    queue: :user_search,
    max_attempts: 3,
    unique: [period: 30]

  alias ElixirInternalCertificate.Repo
  alias ElixirInternalCertificate.Scraper.{ScraperEngine, Scrapers}
  alias ElixirInternalCertificateWorker.Scraper.HtmlParsingHelper

  @max_attempts 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_search_id" => user_search_id}, attempt: @max_attempts}) do
    {:ok, _} = update_user_search(user_search_id, :failed)

    {:error, "max attempts reached, attempt: #{@max_attempts}"}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_search_id" => user_search_id}}) do
    {_, searching_keyword} = update_user_search(user_search_id, :in_progress)

    {:ok, html_response} = ScraperEngine.get_html(searching_keyword.keyword)

    {:ok, search_result} = HtmlParsingHelper.parsing(html_response)

    Repo.transaction(fn ->
      {:ok, _} =
        Scrapers.save_search_result(Map.put(search_result, :user_search_id, user_search_id))

      {:ok, _} = update_user_search(user_search_id, :success)
    end)

    :ok
  end

  defp update_user_search(user_search_id, status) do
    user_search_id
    |> Scrapers.get_user_search()
    |> Scrapers.update_user_search_status(status)
  end
end
