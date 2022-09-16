defmodule ElixirInternalCertificateWeb.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Scraper.Scrapers
  alias ElixirInternalCertificateWeb.CsvParsingHelper
  alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

  def index(%{assigns: %{current_user: %{id: user_id}}} = conn, params) do
    case Integer.parse(Map.get(params, "page", "1"), 10) do
      :error ->
        conn
        |> put_flash(:error, "Page param error")
        |> redirect(to: "/keywords")

      {page, ""} ->
        data = Scrapers.get_user_searches(user_id, page)
        render(conn, "index.html", data: data.entries, meta: build_meta_attrs(data))
    end
  end

  def show(%{assigns: %{current_user: %{id: user_id}}} = conn, %{"id" => id}) do
    %{search_results: [data]} = Scrapers.get_user_search(user_id, id)
    render(conn, "show.html", data: data)
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

  defp build_meta_attrs(payload) do
    %{
      page: payload.page_number,
      page_size: payload.page_size,
      total_pages: payload.total_pages,
      total_entries: payload.total_entries
    }
  end
end
