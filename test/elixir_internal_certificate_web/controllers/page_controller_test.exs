defmodule ElixirInternalCertificateWeb.PageControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET index/2" do
    test "when logged in user click on detail button, returns keyword result", %{conn: conn} do
      user = insert(:user)
      user_search = insert(:user_search, id: 1, user: user)
      insert(:search_result, user_search: user_search)

      conn =
        conn
        |> log_in_user(user)
        |> get("/")
        |> get("/keywords")

      assert html_response(conn, 200) =~ "Select CSV file, maximum 1000 keywords contained"
    end

    test "when unauthenticated, returns login page", %{conn: conn} do
      response =
        conn
        |> bypass_through(ElixirInternalCertificateWeb.Router, :browser)
        |> get("/")
        |> get("/users/log_in")
        |> html_response(200)

      assert response =~ "Login"
    end
  end
end
