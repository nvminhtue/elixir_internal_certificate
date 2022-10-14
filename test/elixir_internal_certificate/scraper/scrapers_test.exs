defmodule ElixirInternalCertificate.Scraper.ScrapersTest do
  use ElixirInternalCertificate.DataCase, async: true

  alias ElixirInternalCertificate.Repo
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

  describe "get_user_search/1" do
    test "with an existed user_search record, returns user_search as given id" do
      user_search = insert(:user_search, keyword: "dog")

      assert user_search ==
               user_search.id
               |> Scrapers.get_user_search()
               |> Repo.preload(:user)
    end

    test "with an not existed record id, returns nil" do
      insert(:user_search, keyword: "dog")

      assert Scrapers.get_user_search(-1) == nil
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
end
