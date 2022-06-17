defmodule ElixirInternalCertificateWeb.CsvParsingHelper do
  alias NimbleCSV.RFC4180, as: CSV

  @max_keyword_upload_count 1000
  @min_keyword_upload_count 0
  @string_length 255

  @csv_file_extension "text/csv"

  def validate_and_parse_keyword_file(file) do
    with true <- file_valid?(file),
         {:ok, keywords} <- parse_keyword_file(file) do
      {:ok, keywords}
    else
      false -> {:error, :invalid_extension}
      :error -> {:error, :invalid_length}
    end
  end

  defp file_valid?(file), do: file.content_type == @csv_file_extension

  defp parse_keyword_file(file) do
    keywords =
      file.path
      |> File.stream!()
      |> CSV.parse_stream(skip_headers: false)
      |> Enum.to_list()
      |> List.flatten()

    keywords_length = Enum.count(keywords)

    if keywords_length > @min_keyword_upload_count &&
         keywords_length <= @max_keyword_upload_count &&
         !Enum.find_value(keywords, &(String.length(&1) > @string_length)) do
      {:ok, keywords}
    else
      :error
    end
  end
end
