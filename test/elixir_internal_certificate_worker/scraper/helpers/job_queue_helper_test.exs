defmodule ElixirInternalCertificateWorker.Scraper.JobQueueHelperTest do
  use Oban.Testing, repo: ElixirInternalCertificate.Repo
  use ElixirInternalCertificate.DataCase, async: true

  alias ElixirInternalCertificateWorker.Scraper.{JobQueueHelper, UserSearchWorker}

  describe "create_searching_queue/1" do
    test "give 2 uploaded keywords, create 2 separate jobs" do
      first_keyword = insert(:user_search, keyword: "first")
      second_keyword = insert(:user_search, keyword: "second")

      JobQueueHelper.create_searching_queue([
        first_keyword,
        second_keyword
      ])

      assert_enqueued(
        worker: UserSearchWorker,
        args: %{user_search_id: first_keyword.id}
      )

      assert_enqueued(
        worker: UserSearchWorker,
        args: %{user_search_id: second_keyword.id}
      )
    end
  end
end
