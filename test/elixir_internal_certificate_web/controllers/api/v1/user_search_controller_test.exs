defmodule ElixirInternalCertificateWeb.Api.V1.UserSearchControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET index/2" do
    test "when logged in user, returns list of keywords and 200 status", %{conn: conn} do
      user = insert(:user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)
      insert(:user_search, keyword: "keyword 2", status: :pending, user: user)
      _another_user_keyword = insert(:user_search)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_user_search_path(conn, :index))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "keyword" => "keyword 1",
                     "status" => "success"
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "user_search"
                 },
                 %{
                   "attributes" => %{
                     "keyword" => "keyword 2",
                     "status" => "pending"
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "user_search"
                 }
               ],
               "included" => [],
               "meta" => %{
                 "page" => 1,
                 "page_size" => 10,
                 "total_entries" => 2,
                 "total_pages" => 1
               }
             } = json_response(conn, 200)
    end

    test "when logged in user, given a valid page number, returns list of keywords and 200 status",
         %{conn: conn} do
      user = insert(:user)
      insert_list(10, :user_search, user: user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)
      _another_user_keyword = insert(:user_search)

      conn =
        conn
        |> token_auth_user(user)
        |> get("/api/v1/keywords/?page=2")

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "keyword" => "keyword 1",
                     "status" => "success"
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "user_search"
                 }
               ],
               "included" => [],
               "meta" => %{
                 "page" => 2,
                 "page_size" => 10,
                 "total_entries" => 11,
                 "total_pages" => 2
               }
             } = json_response(conn, 200)
    end

    test "when logged in user, given a valid page number and valid keyword,
      returns list of mapping keywords and 200 status",
         %{conn: conn} do
      user = insert(:user)
      insert_list(10, :user_search, keyword: "keyword", user: user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)
      _another_user_keyword = insert(:user_search)

      conn =
        conn
        |> token_auth_user(user)
        |> get("/api/v1/keywords/?page=2&q=1")

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "keyword" => "keyword 1",
                     "status" => "success"
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "user_search"
                 }
               ],
               "included" => [],
               "meta" => %{
                 "page" => 1,
                 "page_size" => 10,
                 "total_entries" => 1,
                 "total_pages" => 1
               }
             } = json_response(conn, 200)
    end

    test "when logged in user, given a valid page number and NOT FOUND keyword,
      returns list of mapping keywords and 200 status",
         %{conn: conn} do
      user = insert(:user)
      insert_list(10, :user_search, keyword: "keyword", user: user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)
      _another_user_keyword = insert(:user_search)

      conn =
        conn
        |> token_auth_user(user)
        |> get("/api/v1/keywords/?page=2&q=not_found")

      assert %{
               "data" => [],
               "included" => [],
               "meta" => %{
                 "page" => 1,
                 "page_size" => 10,
                 "total_entries" => 0,
                 "total_pages" => 1
               }
             } = json_response(conn, 200)
    end

    test "when logged in user, given an INVALID page number, returns error and 422 status",
         %{conn: conn} do
      user = insert(:user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)

      conn =
        conn
        |> token_auth_user(user)
        |> get("/api/v1/keywords/?page=one")

      assert %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => "Page param error"
                 }
               ]
             } = json_response(conn, 422)
    end

    test "when unauthenticated user, returns 401 status",
         %{conn: conn} do
      user = insert(:user)
      insert(:user_search, keyword: "keyword 1", status: :success, user: user)
      _another_user_keyword = insert(:user_search)

      conn =
        conn
        |> put_resp_content_type("application/json")
        |> get("/api/v1/keywords/?page=2")

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{"code" => "unauthorized", "detail" => "unauthenticated"}
               ]
             }
    end
  end
end
