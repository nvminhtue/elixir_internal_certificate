defmodule ElixirInternalCertificateWeb.UserSearchView do
  use ElixirInternalCertificateWeb, :view

  def get_status(value) do
    cond do
      value == :pending -> "text-warning"
      value == :in_progress -> "text-info"
      value == :failed -> "text-danger"
      value == :success -> "text-success"
    end
  end

  def is_active_page?(_page, nil), do: nil

  def is_active_page?(page, target), do: if(page == target, do: "active", else: "")

  def build_href_query(conn, page) when is_number(page),
    do: "/keywords?page=#{page}#{append_search_query(conn)}"

  defp append_search_query(conn) do
    search_query_value = conn.query_params["q"]

    if conn.query_params["q"] do
      "&q=#{search_query_value}"
    else
      ""
    end
  end
end
