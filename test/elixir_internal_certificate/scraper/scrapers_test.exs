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

      assert Scrapers.insert_search_keywords(valid_user_search_attributes(attrs, user)) == {2, nil}
    end
  end

  describe "create_search_keyword/2" do
    test "with 2 valid keyword, it should returns value of 2" do
      user = insert(:user)

      attrs = [
        ExMachina.Sequence.next("alphabet_sequence", ["A", "B"]),
        ExMachina.Sequence.next("alphabet_sequence", ["A", "B"])
      ]

      assert Scrapers.create_search_keyword(attrs, user) == 2
    end

    test "with no keyword imported, it should return value of 0" do
      user = insert(:user)
      attrs = []

      assert Scrapers.create_search_keyword(attrs, user) == 0
    end
  end
end
