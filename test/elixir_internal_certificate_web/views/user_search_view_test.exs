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

  describe "build_href_query/1" do
    test "with an existing query params and valid page, returns the valid query string" do
        assert UserSearchView.build_href_query(%{query_params: %{"q" => "keyword"}}, 1) == "/keywords?page=1&q=keyword"
    end

    test "with a blank query params and valid page, returns a valid query string without search keyword" do
      assert UserSearchView.build_href_query(%{query_params: %{}}, 1) == "/keywords?page=1"
    end

    test "with a valid query params and INVALID page, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        UserSearchView.build_href_query(%{query_params: %{}}, "invalid")
      end
    end

    test "with a blank query params and INVALID page, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        UserSearchView.build_href_query(%{query_params: %{}}, "invalid")
      end
    end
  end
end
