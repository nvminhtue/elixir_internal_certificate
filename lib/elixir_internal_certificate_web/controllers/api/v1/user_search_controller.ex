defmodule ElixirInternalCertificateWeb.Api.V1.UserSearchController do
  use ElixirInternalCertificateWeb, :controller

  alias ElixirInternalCertificate.Scraper.Scrapers
  alias ElixirInternalCertificateWeb.Api.ErrorView

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

  defp build_meta_attrs(payload) do
    %{
      page: payload.page_number,
      page_size: payload.page_size,
      total_pages: payload.total_pages,
      total_entries: payload.total_entries
    }
  end
end
