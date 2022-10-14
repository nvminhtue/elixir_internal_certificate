defmodule ElixirInternalCertificateWeb.CsvParsingHelperTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificateWeb.CsvParsingHelper

  describe "validate_and_parse_keyword_file/1" do
    test "when file is valid, returns ok" do
      file = upload_dummy_file("valid.csv")

      assert CsvParsingHelper.validate_and_parse_keyword_file(file) == {
               :ok,
               ["this", " is", " the", " test", " file"]
             }
    end

    test "when file is invalid extension, returns error" do
      file = upload_dummy_file("invalid_extension.csve")

      assert CsvParsingHelper.validate_and_parse_keyword_file(file) == {
               :error,
               :invalid_extension
             }
    end

    test "when file has exceeded keyword, returns error" do
      file = upload_dummy_file("exceed_char.csv")

      assert CsvParsingHelper.validate_and_parse_keyword_file(file) == {
               :error,
               :invalid_length
             }
    end

    test "when file has exceeded 1000 keywords, returns error" do
      file = upload_dummy_file("exceed_keyword.csv")

      assert CsvParsingHelper.validate_and_parse_keyword_file(file) == {
               :error,
               :invalid_length
             }
    end

    test "when file has no keyword, returns error" do
      file = upload_dummy_file("empty.csv")

      assert CsvParsingHelper.validate_and_parse_keyword_file(file) == {
               :error,
               :invalid_length
             }
    end
  end
end
