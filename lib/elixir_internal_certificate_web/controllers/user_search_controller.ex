defmodule ElixirInternalCertificateWeb.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Scraper.Scrapers
  alias ElixirInternalCertificateWeb.CsvParsingHelper
  alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes
  alias ElixirInternalCertificateWorker.Scrapper.JobQueueHelper

  def index(conn, _params), do: render(conn, "index.html")

  @doc """
  Handle uploaded CSV data
  """
  def upload(conn, %{"file" => file}) do
    case CsvParsingHelper.validate_and_parse_keyword_file(file) do
      {:ok, keywords} ->
        result = Scrappers.create_user_search(keywords, conn.assigns.current_user)
        {keywords_count, uploaded_keywords} = result
        JobQueueHelper.create_searching_queue(uploaded_keywords)

        conn
        |> put_flash(:info, "File successfully uploaded. #{keywords_count} keywords uploaded.")
        |> redirect(to: Routes.user_search_path(conn, :index))

      {:error, :invalid_extension} ->
        conn
        |> put_flash(:error, "File extension invalid, csv only")
        |> redirect(to: Routes.user_search_path(conn, :index))

      {:error, :invalid_length} ->
        conn
        |> put_flash(:error, "Length invalid. 1-1000 keywords within 255 characters only")
        |> redirect(to: Routes.user_search_path(conn, :index))
    end
  end
end
