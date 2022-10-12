defmodule ElixirInternalCertificateWeb.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Scraper.Scrapers
  alias ElixirInternalCertificateWeb.CsvParsingHelper
  alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  @doc """
  Handle uploaded CSV data
  """
  def upload(conn, %{"file" => file}) do
    case CsvParsingHelper.validate_and_parse_keyword_file(file) do
      {:ok, keywords} ->
        keywords_count = Scrapers.create_user_search(keywords, conn.assigns.current_user)

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
