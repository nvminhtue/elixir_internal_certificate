defmodule ElixirInternalCertificate.Scraper.ScraperEngine do
  @google_search_url "https://www.google.com/search?q="
  @headers [
    {
      "User-Agent",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36"
    },
    {
      "Accept-Language",
      "en-US,en;q=0.9,it;q=0.8"
    },
    {
      "X-Forwarded-For",
      "#{:rand.uniform(255)}.#{:rand.uniform(255)}.#{:rand.uniform(255)}.#{:rand.uniform(255)}"
    }
  ]

  def get_html(keyword) do
    search_query = @google_search_url <> URI.encode(keyword)

    case HTTPoison.get(search_query, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, "Internal server error"}

      {:ok, response = %HTTPoison.Response{status_code: _}} ->
        {:error, response}
    end
  end
end
