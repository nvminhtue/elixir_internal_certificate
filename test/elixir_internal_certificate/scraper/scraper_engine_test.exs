defmodule ElixirInternalCertificate.Scraper.ScraperEngineTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias ElixirInternalCertificate.Scraper.ScraperEngine

  setup_all do
    HTTPoison.start()
  end

  describe "get_html/1" do
    test "given a keyword, returns ok and body" do
      use_cassette "scrapers/search_dog" do
        assert {:ok, _html_respone} = ScraperEngine.get_html("dog")
      end
    end

    test "given a keyword and error with status code 500, returns error and description" do
      use_cassette :stub, url: "https://www.google.com/search?q=dog", status_code: 500 do
        assert {:error, "Internal server error"} = ScraperEngine.get_html("dog")
      end
    end

    test "given a keyword and error with unhandled status code 504, returns error and HTTPPoison response" do
      use_cassette(:stub, url: "https://www.google.com/search?q=dog", status_code: 504) do
        assert {:error, %HTTPoison.Response{}} = ScraperEngine.get_html("dog")
      end
    end
  end
end
