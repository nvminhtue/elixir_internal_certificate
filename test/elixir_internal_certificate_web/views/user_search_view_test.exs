defmodule ElixirInternalCertificateWeb.UserSearchViewTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificateWeb.UserSearchView

  describe "get_status/2" do
    test "with value of pending, returns text-warning",
      do: assert(UserSearchView.get_status(:pending) == "text-warning")

    test "with value of in_progress, returns text-info",
      do: assert(UserSearchView.get_status(:in_progress) == "text-info")

    test "with value of failed, returns text-danger",
      do: assert(UserSearchView.get_status(:failed) == "text-danger")

    test "with value of success, returns text-success",
      do: assert(UserSearchView.get_status(:success) == "text-success")
  end

  describe "is_active_page?/2" do
    test "with the same page and target, returns active status",
      do: assert(UserSearchView.is_active_page?(1, 1) == "active")

    test "with the different page and target, returns blank status",
      do: assert(UserSearchView.is_active_page?(1, 2) == "")

    test "with the nil target, returns nil status",
      do: assert(UserSearchView.is_active_page?(1, nil) == nil)
  end

  describe "append_search_query/1" do
    test "with an existing query params, returns the valid query string",
      do: assert(UserSearchView.append_search_query(%{query_params: %{"q" => "keyword"}}) == "&q=keyword")

    test "with a blank query params, returns the blank string",
      do: assert(UserSearchView.append_search_query(%{query_params: %{}}) == "")
  end
end
