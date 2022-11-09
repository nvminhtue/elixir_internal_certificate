defmodule ElixirInternalCertificateWeb.Api.V1.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Scraper.Scrapers
  alias ElixirInternalCertificateWeb.Api.ErrorView
  alias ElixirInternalCertificateWeb.Api.V1.{KeywordUploadView, SearchResultView}
  alias ElixirInternalCertificateWeb.CsvParsingHelper

  def index(
        %{
          private:
            %{guardian_default_claims: %{"sub" => user_id} = _guardian_default_claims} = _private
        } = conn,
        params
      ) do
    with {page, ""} <- Integer.parse(Map.get(params, "page", "1"), 10),
         search_keyword <- Map.get(params, "q", ""),
         data <- Scrapers.get_user_searches(user_id, search_keyword, page) do
      render(conn, "index.json", %{
        data: data.entries,
        meta: build_meta_attrs(data)
      })
    else
      _error ->
        conn
        |> put_view(ErrorView)
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{code: :unprocessable_entity, detail: "Page param error"})
    end
  end

  def show(
        %{
          private:
            %{guardian_default_claims: %{"sub" => user_id} = _guardian_default_claims} = _private
        } = conn,
        %{"id" => id} = _params
      ) do
    case Scrapers.get_user_search_by_user_id_and_id(user_id, id) do
      %{search_results: [data]} ->
        conn
        |> put_view(SearchResultView)
        |> render("show.json", %{
          data: data
        })

      nil ->
        conn
        |> put_view(ErrorView)
        |> put_status(:not_found)
        |> render("error.json", %{
          code: :not_found,
          detail: "Not found"
        })
    end
  end

  def upload(
        %{
          private:
            %{guardian_default_claims: %{"sub" => sub_user_id} = _guardian_default_claims} =
              _private
        } = conn,
        %{"file" => file}
      ) do
    with {:ok, keywords} <- CsvParsingHelper.validate_and_parse_keyword_file(file),
         {user_id, _} <- Integer.parse(sub_user_id, 10),
         {_keywords_count, uploaded_keywords} <- Scrapers.create_user_search(keywords, user_id) do
      conn
      |> put_view(KeywordUploadView)
      |> render("show.json", %{
        data: uploaded_keywords
      })
    else
      {:error, :invalid_extension} ->
        conn
        |> put_view(ErrorView)
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{
          code: :unprocessable_entity,
          detail: "File extension invalid, csv only"
        })

      {:error, :invalid_length} ->
        conn
        |> put_view(ErrorView)
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{
          code: :unprocessable_entity,
          detail: "Length invalid. 1-1000 keywords within 255 characters only"
        })
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
