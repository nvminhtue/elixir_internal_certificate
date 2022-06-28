defmodule ElixirInternalCertificateWorker.Scraper.UserSearchWorkerTest do
  use ElixirInternalCertificate.DataCase, async: false

  alias ElixirInternalCertificate.Scraper.Schemas.SearchResult
  alias ElixirInternalCertificateWorker.Scraper.UserSearchWorker

  @max_attempts 3

  setup_all do
    HTTPoison.start()
  end

  describe "perform/1" do
    test "updates status to inprogress for the uploaded keyword" do
      use_cassette "scrapers/search_tv" do
        user_search = insert(:user_search, keyword: "tivi samsung 4k")

        assert user_search.status == :pending

        UserSearchWorker.perform(%Oban.Job{args: %{"user_search_id" => user_search.id}})

        reloaded_user_search = Repo.reload(user_search)
        search_result = Repo.all(SearchResult)
        search_result_record = Enum.at(search_result, 0)

        assert reloaded_user_search.status == :success
        assert reloaded_user_search.keyword == "tivi samsung 4k"
        assert Enum.count(search_result) == 1
        assert search_result_record.ad_words_total == 6
        assert search_result_record.top_ad_words_total == 5
        assert search_result_record.non_ad_words_total == 9
        assert search_result_record.links_total == 15
        assert search_result_record.html_response =~ "<!doctype html>"
        assert Enum.count(search_result_record.top_ad_words_links) == 5
        assert Enum.count(search_result_record.non_ad_words_links) == 9
      end
    end

    test "updates status to failed when max attempts have been reached" do
      use_cassette "scrapers/search_tv_failed" do
        user_search = insert(:user_search, keyword: "tivi samsung 4k failed")

        UserSearchWorker.perform(%Oban.Job{
          args: %{"user_search_id" => user_search.id},
          attempt: @max_attempts
        })

        %{status: status} = Repo.reload(user_search)
        search_result = Repo.all(SearchResult)

        assert status == :failed
        assert Enum.empty?(search_result)
      end
    end
  end
end
