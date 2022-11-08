defmodule ElixirInternalCertificateWeb.Api.V1.UserSearchControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET index/2" do
    test "when logged in user, returns list of keywords and 200 status", %{conn: conn} do
      user = insert(:user)

      insert(:user_search,
        keyword: "keyword 1",
        status: :success,
        inserted_at: ~N[2022-10-11 00:00:00],
        user: user
      )

      insert(:user_search,
        keyword: "keyword 2",
        status: :pending,
        inserted_at: ~N[2022-10-10 00:00:00],
        user: user
      )

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
      insert_list(10, :user_search, inserted_at: ~N[2022-10-10 00:00:00], user: user)

      insert(:user_search,
        keyword: "keyword 1",
        status: :success,
        inserted_at: ~N[2022-10-09 00:00:00],
        user: user
      )

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
                 %{"code" => "unauthorized", "detail" => "Login required"}
               ]
             }
    end
  end

  describe "GET show/2" do
    test "when logged in user, given a valid user_search id, returns result and 200 status", %{
      conn: conn
    } do
      user = insert(:user)
      user_search = insert(:user_search, status: :success, user: user, id: 1)

      %{
        ad_words_total: ad_words_total,
        html_response: html_response,
        links_total: links_total,
        non_ad_words_links: non_ad_words_links,
        non_ad_words_total: non_ad_words_total,
        top_ad_words_links: top_ad_words_links,
        top_ad_words_total: top_ad_words_total
      } =
        _search_result =
        insert(
          :search_result,
          user_search: user_search,
          id: 3
        )

      another_user_keyword = insert(:user_search, id: 2)
      _another_search_result = insert(:search_result, user_search: another_user_keyword, id: 4)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_user_search_path(conn, :show, 1))

      assert %{
               "data" => %{
                 "attributes" => %{
                   "ad_words_total" => ^ad_words_total,
                   "html_response" => ^html_response,
                   "links_total" => ^links_total,
                   "non_ad_words_links" => ^non_ad_words_links,
                   "non_ad_words_total" => ^non_ad_words_total,
                   "top_ad_words_links" => ^top_ad_words_links,
                   "top_ad_words_total" => ^top_ad_words_total
                 },
                 "id" => "3",
                 "relationships" => %{},
                 "type" => "search_result"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "when logged in user, given a not existing user_search id, returns 404 status",
         %{conn: conn} do
      user = insert(:user)
      user_search = insert(:user_search, status: :success, user: user, id: 1)

      _search_result =
        insert(
          :search_result,
          user_search: user_search,
          id: 3
        )

      another_user_keyword = insert(:user_search, id: 2)
      _another_search_result = insert(:search_result, user_search: another_user_keyword, id: 4)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_user_search_path(conn, :show, 2))

      assert %{"errors" => [%{"code" => "not_found", "detail" => "Not found"}]} =
               json_response(conn, 404)
    end

    test "when logged in user, given a existing user_search id belonged to another use, returns 404 status",
         %{conn: conn} do
      user = insert(:user)
      another_user_search = insert(:user_search, status: :success, id: 1)
      _another_search_result = insert(:search_result, user_search: another_user_search, id: 4)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_user_search_path(conn, :show, 1))

      assert %{"errors" => [%{"code" => "not_found", "detail" => "Not found"}]} =
               json_response(conn, 404)
    end

    test "when unauthenticated user, returns 401 status",
         %{conn: conn} do
      user = insert(:user)
      user_search = insert(:user_search, status: :success, user: user, id: 1)

      _search_result =
        insert(
          :search_result,
          user_search: user_search,
          id: 3
        )

      conn =
        conn
        |> put_resp_content_type("application/json")
        |> get(Routes.api_user_search_path(conn, :show, 2))

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{"code" => "unauthorized", "detail" => "unauthenticated"}
               ]
             }
    end
  end
end
