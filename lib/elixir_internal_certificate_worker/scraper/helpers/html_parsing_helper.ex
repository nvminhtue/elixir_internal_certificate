defmodule ElixirInternalCertificateWorker.Scraper.HtmlParsingHelper do
  def parsing(html_body) do
    {:ok, analyzed_data} = analyzing_html_body(html_body)

    {:ok, calculated_data} = calculating_result(analyzed_data)

    {:ok,
     %{
       ad_words_total: calculated_data.ad_words_total,
       top_ad_words_total: Enum.count(calculated_data.top_ad_words_links),
       non_ad_words_total: calculated_data.non_ad_words_total,
       links_total: calculated_data.link_total,
       html_response: html_body,
       non_ad_words_links: calculated_data.non_ad_words_links,
       top_ad_words_links: calculated_data.top_ad_words_links
     }}
  end

  defp analyzing_html_body(html_body) do
    sliced_non_ad_words =
      Regex.scan(
        ~r/a href=(.+?) data-ved="(.+?)" ping=(.+?);url=(.+?)&amp(.+?)><br>/,
        html_body
      )

    sliced_ad_words_posts =
      Regex.scan(
        ~r/data-rw=(.+?)" href="https:\/\/(.+?)" data-ae="1" data-al="1" data-ved=(.+?)<br>/,
        html_body
      )

    has_banner_ad =
      Regex.scan(
        ~r/commercial-unit-desktop-top">(.+?)<a data-impdclcc="1" href="(.+?)" data-agdh="arwt"/,
        html_body
      )

    banner_ad =
      Regex.scan(
        ~r/<div class="pla-unit-container">(.+?)<a data-impdclcc="1" href="(.+?)" data-agdh="arwt"/,
        html_body
      )

    {:ok,
     %{
       sliced_non_ad_words: sliced_non_ad_words,
       sliced_ad_words_posts: sliced_ad_words_posts,
       has_banner_ad: has_banner_ad,
       banner_ad: banner_ad
     }}
  end

  defp calculating_result(analyzed_data) do
    ad_words_total =
      trunc(
        Enum.count(analyzed_data.sliced_ad_words_posts) + Enum.count(analyzed_data.banner_ad) || 0
      )

    non_ad_words_total = trunc(Enum.count(analyzed_data.sliced_non_ad_words) || 0)
    link_total = non_ad_words_total + ad_words_total
    non_ad_words_links = Enum.map(analyzed_data.sliced_non_ad_words, &Enum.slice(&1, -2, 1))

    top_ad_words_links =
      (Enum.count(analyzed_data.has_banner_ad) != 0 &&
         Enum.map(analyzed_data.banner_ad, &Enum.slice(&1, -1, 1))) ||
        []

    {:ok,
     %{
       ad_words_total: ad_words_total,
       non_ad_words_total: non_ad_words_total,
       link_total: link_total,
       non_ad_words_links: non_ad_words_links,
       top_ad_words_links: top_ad_words_links
     }}
  end
end
