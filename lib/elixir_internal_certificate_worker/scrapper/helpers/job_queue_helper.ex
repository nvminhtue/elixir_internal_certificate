defmodule ElixirInternalCertificateWorker.Scrapper.JobQueueHelper do
  alias ElixirInternalCertificateWorker.Scrapper.UserSearchWorker

  def create_searching_queue(uploaded_keywords) do
    uploaded_keywords
    |> Enum.map(&UserSearchWorker.new(%{user_search_id: &1.id}))
    |> Oban.insert_all()
  end
end
