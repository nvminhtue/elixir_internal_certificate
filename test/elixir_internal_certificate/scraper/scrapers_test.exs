defmodule ElixirInternalCertificate.Scraper.ScrapersTest do
  use ElixirInternalCertificate.DataCase, async: true

  alias ElixirInternalCertificate.Scraper.Scrapers

  describe "insert_search_keywords/1" do
    test "with 2 valid keyword, it should create 2 records" do
      user = insert(:user)

      attrs = [
        %{keyword: ExMachina.Sequence.next("alphabet_sequence", ["A", "B"])},
        %{keyword: ExMachina.Sequence.next("alphabet_sequence", ["A", "B"])}
      ]

      {keywords_count, uploaded_keywords} =
        Scrapers.insert_search_keywords(valid_user_search_attributes(attrs, user))

      assert keywords_count == 2
      assert Enum.at(uploaded_keywords, 0).keyword == "A"
      assert Enum.at(uploaded_keywords, 1).keyword == "B"
    end
  end

  describe "create_user_search/2" do
    test "with 2 valid keyword, it should returns value of 2" do
      user = insert(:user)

      attrs = [
        ExMachina.Sequence.next("alphabet_sequence", ["A", "B"]),
        ExMachina.Sequence.next("alphabet_sequence", ["A", "B"])
      ]

      keywords_count = Scrapers.create_user_search(attrs, user)

      assert keywords_count == 2
    end

    test "with no keyword imported, it should return value of 0" do
      user = insert(:user)
      attrs = []

      keywords_count = Scrapers.create_user_search(attrs, user)

      assert keywords_count == 0
    end
  end

  describe "update_user_search_status/2" do
    test "given user_search and status, returns status updated user_search record" do
      user_search = insert(:user_search, keyword: "dog", status: :pending)

      {status, result} = Scrapers.update_user_search_status(user_search, :success)

      assert status == :ok
      assert result.keyword == "dog"
      assert result.status == :success
    end
  end

  describe "save_search_result/1" do
    test "with scrapped result, returns search_results" do
      user_search = insert(:user_search, keyword: "dog", status: :in_progress)

      top_ad_words_total = 2
      ad_words_total = 3
      non_ad_words_total = 4
      links_total = 7
      html_response = "<html></html>"
      top_ad_words_links = ["https://top1.com", "https://top2.com"]

      non_ad_words_links = [
        "https://non-ad1.com",
        "https://non-ad2.com",
        "https://non-ad3.com",
        "https://non-ad4.com"
      ]

      attrs = %{
        top_ad_words_total: top_ad_words_total,
        ad_words_total: ad_words_total,
        non_ad_words_total: non_ad_words_total,
        links_total: links_total,
        html_response: html_response,
        user_search_id: user_search.id,
        top_ad_words_links: top_ad_words_links,
        non_ad_words_links: non_ad_words_links
      }

      {status, result} = Scrapers.save_search_result(attrs)

      assert status == :ok
      assert result.links_total == 7
      assert result.ad_words_total == 3
      assert result.top_ad_words_total == 2
      assert result.non_ad_words_total == 4
      assert result.html_response == "<html></html>"
      assert Enum.count(result.top_ad_words_links) == 2
      assert Enum.count(result.non_ad_words_links) == 4
    end

    test "with scrapped result has no html, returns error" do
      user_search = insert(:user_search, keyword: "dog", status: :in_progress)

      top_ad_words_total = 2
      ad_words_total = 3
      non_ad_words_total = 4
      links_total = 7
      html_response = ""
      top_ad_words_links = ["https://top1.com", "https://top2.com"]

      non_ad_words_links = [
        "https://non-ad1.com",
        "https://non-ad2.com",
        "https://non-ad3.com",
        "https://non-ad4.com"
      ]

      attrs = %{
        top_ad_words_total: top_ad_words_total,
        ad_words_total: ad_words_total,
        non_ad_words_total: non_ad_words_total,
        links_total: links_total,
        html_response: html_response,
        user_search_id: user_search.id,
        top_ad_words_links: top_ad_words_links,
        non_ad_words_links: non_ad_words_links
      }

      {error, change} = Scrapers.save_search_result(attrs)

      assert error
      assert change.errors == [html_response: {"can't be blank", [validation: :required]}]
    end

    test "with scrapped result has negative value of top_ad_words_total, returns error" do
      user_search = insert(:user_search, keyword: "dog", status: :in_progress)

      top_ad_words_total = -1
      ad_words_total = 3
      non_ad_words_total = 4
      links_total = 7
      html_response = "<html></html>"
      top_ad_words_links = ["https://top1.com", "https://top2.com"]

      non_ad_words_links = [
        "https://non-ad1.com",
        "https://non-ad2.com",
        "https://non-ad3.com",
        "https://non-ad4.com"
      ]

      attrs = %{
        top_ad_words_total: top_ad_words_total,
        ad_words_total: ad_words_total,
        non_ad_words_total: non_ad_words_total,
        links_total: links_total,
        html_response: html_response,
        user_search_id: user_search.id,
        top_ad_words_links: top_ad_words_links,
        non_ad_words_links: non_ad_words_links
      }

      {error, change} = Scrapers.save_search_result(attrs)

      assert error

      assert change.errors == [
               top_ad_words_total: {
                 "must be greater than or equal to %{number}",
                 [validation: :number, kind: :greater_than_or_equal_to, number: 0]
               }
             ]
    end

    test "with scrapped result has negative value of non_ad_words_total, returns error" do
      user_search = insert(:user_search, keyword: "dog", status: :in_progress)

      top_ad_words_total = 2
      ad_words_total = 3
      non_ad_words_total = -1
      links_total = 7
      html_response = "<html></html>"
      top_ad_words_links = ["https://top1.com", "https://top2.com"]

      non_ad_words_links = [
        "https://non-ad1.com",
        "https://non-ad2.com",
        "https://non-ad3.com",
        "https://non-ad4.com"
      ]

      attrs = %{
        top_ad_words_total: top_ad_words_total,
        ad_words_total: ad_words_total,
        non_ad_words_total: non_ad_words_total,
        links_total: links_total,
        html_response: html_response,
        user_search_id: user_search.id,
        top_ad_words_links: top_ad_words_links,
        non_ad_words_links: non_ad_words_links
      }

      {error, change} = Scrapers.save_search_result(attrs)

      assert error

      assert change.errors == [
               non_ad_words_total: {
                 "must be greater than or equal to %{number}",
                 [validation: :number, kind: :greater_than_or_equal_to, number: 0]
               }
             ]
    end
  end

  describe "get_user_search/1" do
    test "given a valid numeric type of user_search id with existing search_results data, returns user_search and preloaded search_results" do
      search_results =
        insert(:search_result,
          user_search: build(:user_search, keyword: "dog", status: :success, id: 1)
        )

      assert user_search_result = Scrapers.get_user_search(1)
      assert user_search_result.id == 1
      assert user_search_result.status == :success
      assert user_search_result.keyword == "dog"
      assert Enum.at(user_search_result.search_results, 0).id == search_results.id
    end

    test "given a valid string type of user_search id with existing search_results data, returns user_search and preloaded search_results" do
      search_results =
        insert(:search_result,
          user_search: build(:user_search, keyword: "dog", status: :success, id: 1)
        )

      assert user_search_result = Scrapers.get_user_search("1")
      assert user_search_result.id == 1
      assert user_search_result.status == :success
      assert user_search_result.keyword == "dog"
      assert Enum.at(user_search_result.search_results, 0).id == search_results.id
    end

    test "given a valid user_search id with NON-existing search_results data, returns user_search and nil search_result" do
      insert(:user_search, keyword: "dog", status: :in_progress, id: 1)

      assert user_search_result = Scrapers.get_user_search("1")
      assert user_search_result.id == 1
      assert user_search_result.status == :in_progress
      assert user_search_result.keyword == "dog"
      assert Enum.at(user_search_result.search_results, 0) == nil
    end

    test "given a NON-existing user_search id, returns nil" do
      insert(:user_search)

      assert_raise Ecto.NoResultsError, fn ->
        Scrapers.get_user_search("2")
      end
    end

    test "given an INVALID user_search id, returns error" do
      insert(:user_search)

      assert_raise FunctionClauseError, fn ->
        Scrapers.get_user_search(:invalid)
      end
    end
  end

  describe "get_user_searches/3" do
    test "given a valid user_id, valid page and valid page_size, returns list of user_searches and pagination meta" do
      user = insert(:user)

      insert(:user_search,
        keyword: "dog1",
        status: :in_progress,
        id: 1,
        user: user,
        inserted_at: ~N[2022-01-01 00:00:00]
      )

      insert(:user_search,
        keyword: "dog2",
        status: :in_progress,
        id: 2,
        user: user,
        inserted_at: ~N[2022-01-02 00:00:00]
      )

      assert result = Scrapers.get_user_searches(user.id, 1)

      assert Enum.count(result.entries) == 2
      assert Enum.at(result.entries, 0).id == 2
      assert Enum.at(result.entries, 1).id == 1

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "given a valid user_id having 12 keywords, and valid page 2, returns list of user_searches in page 2 and pagination meta" do
      user = insert(:user)
      insert_list(10, :user_search, user: user, inserted_at: ~N[2022-01-03 00:00:00])

      insert(:user_search,
        keyword: "dog1",
        status: :in_progress,
        id: 11,
        user: user,
        inserted_at: ~N[2022-01-01 00:00:00]
      )

      insert(:user_search,
        keyword: "dog2",
        status: :in_progress,
        id: 12,
        user: user,
        inserted_at: ~N[2022-01-02 00:00:00]
      )

      assert result = Scrapers.get_user_searches(user.id, 2)

      assert Enum.count(result.entries) == 2
      assert Enum.at(result.entries, 0).id == 12
      assert Enum.at(result.entries, 1).id == 11

      assert result.page_number == 2
      assert result.page_size == 10
      assert result.total_entries == 12
      assert result.total_pages == 2
    end

    test "given a valid user_id and blank page param, returns list of user_searches with default first page, 10 page_size and pagination meta" do
      user = insert(:user)

      insert(:user_search,
        keyword: "dog1",
        status: :in_progress,
        id: 1,
        user: user,
        inserted_at: ~N[2022-01-01 00:00:00]
      )

      insert(:user_search,
        keyword: "dog2",
        status: :in_progress,
        id: 2,
        user: user,
        inserted_at: ~N[2022-01-02 00:00:00]
      )

      assert result = Scrapers.get_user_searches(user.id)

      assert Enum.count(result.entries) == 2
      assert Enum.at(result.entries, 0).id == 2
      assert Enum.at(result.entries, 1).id == 1

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "given a valid user_id and an EXCEEDED value of page, returns list of user_searches with default last page, 10 page_size and pagination meta" do
      user = insert(:user)

      insert(:user_search,
        keyword: "dog1",
        status: :in_progress,
        id: 1,
        user: user,
        inserted_at: ~N[2022-01-01 00:00:00]
      )

      insert(:user_search,
        keyword: "dog2",
        status: :in_progress,
        id: 2,
        user: user,
        inserted_at: ~N[2022-01-02 00:00:00]
      )

      assert result = Scrapers.get_user_searches(user.id, 2)

      assert Enum.count(result.entries) == 2
      assert Enum.at(result.entries, 0).id == 2
      assert Enum.at(result.entries, 1).id == 1

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 2
      assert result.total_pages == 1
    end

    test "given a valid user_id of no related user_search record, returns a blank array with pagination meta" do
      user = insert(:user)

      insert(:user_search,
        keyword: "dog1",
        status: :in_progress,
        id: 1,
        inserted_at: ~N[2022-01-01 00:00:00]
      )

      insert(:user_search,
        keyword: "dog2",
        status: :in_progress,
        id: 2,
        inserted_at: ~N[2022-01-02 00:00:00]
      )

      assert result = Scrapers.get_user_searches(user.id)

      assert Enum.empty?(result.entries) == true

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 0
      assert result.total_pages == 1
    end

    test "given an INVALID page param, returns page 1" do
      user = insert(:user)
      insert(:user_search, keyword: "dog", status: :in_progress, id: 1, user: user)

      assert result = Scrapers.get_user_searches(user.id)

      assert Enum.count(result.entries) == 1

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 1
      assert result.total_pages == 1
    end

    test "given an INVALID user_id, returns error" do
      assert result = Scrapers.get_user_searches(10)

      assert Enum.empty?(result.entries) == true

      assert result.page_number == 1
      assert result.page_size == 10
      assert result.total_entries == 0
      assert result.total_pages == 1
    end
  end
end
