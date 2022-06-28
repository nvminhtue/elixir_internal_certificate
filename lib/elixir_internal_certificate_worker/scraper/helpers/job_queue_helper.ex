defmodule ElixirInternalCertificateWorker.Scraper.JobQueueHelper do
  alias ElixirInternalCertificateWorker.Scraper.UserSearchWorker

  def enqueue_user_search_worker(uploaded_keywords) do
    uploaded_keywords
    |> Enum.map(&UserSearchWorker.new(%{user_search_id: &1.id}))
    |> Oban.insert_all()
  end
end
