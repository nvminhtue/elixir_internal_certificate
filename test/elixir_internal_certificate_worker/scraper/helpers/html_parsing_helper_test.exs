defmodule ElixirInternalCertificateWorker.Scraper.HtmlParsingHelperTest do
  use ElixirInternalCertificate.DataCase, async: true

  alias ElixirInternalCertificateWorker.Scraper.HtmlParsingHelper

  describe "parsing/1" do
    test "give a html string, returns parsed data" do
      parsing_html = read_dummy_file("example.html")

      {status, parsed_data} = HtmlParsingHelper.parsing(parsing_html)

      assert status == :ok
      assert parsed_data.ad_words_total == 13
      assert parsed_data.top_ad_words_total == 0
      assert parsed_data.non_ad_words_total == 9
      assert parsed_data.links_total == 22
      assert parsed_data.html_response == parsing_html

      assert parsed_data.non_ad_words_links == [
               "https://www.dienmayxanh.com/tivi-lg%3Fg%3D55-inch",
               "https://www.dienmayxanh.com/tivi-lg",
               "https://mediamart.vn/tivi-lg",
               "https://dienmaycholon.vn/tivi/lg-smart-tivi-4k-55-inch-55up7550ptc",
               "https://www.nguyenkim.com/tivi-lg/",
               "https://www.nguyenkim.com/smart-tivi-lg-4k-55-inch-55up8100ptb.html",
               "https://websosanh.vn/tivi-smart-lg-55um7400pta-55-inch/915606479/so-sanh.htm",
               "https://dienmaygiare.net/tivi/tivi-lg/tivi-lg-55-inch/",
               "https://pico.vn/tivi/lg-cid157-ma51"
             ]

      assert parsed_data.top_ad_words_links == []
    end
  end
end
