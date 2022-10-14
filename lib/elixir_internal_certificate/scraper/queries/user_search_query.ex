defmodule ElixirInternalCertificate.Scraper.Queries.UserSearchQuery do
  import Ecto.Query, warn: false

  alias ElixirInternalCertificate.Scraper.Schemas.UserSearch

  def fetch_user_search_by_user_id_and_keyword(user_id, ""),
    do: fetch_user_search_by_user_id(user_id)

  def fetch_user_search_by_user_id_and_keyword(user_id, keyword) do
    user_id
    |> fetch_user_search_by_user_id()
    |> where([u], ilike(u.keyword, ^"%#{keyword}%"))
  end

  defp fetch_user_search_by_user_id(user_id) do
    UserSearch
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
  end
end
