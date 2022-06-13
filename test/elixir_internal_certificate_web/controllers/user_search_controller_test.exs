defmodule ElixirInternalCertificateWeb.UserSearchControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET /" do
    test "when logged in user, returns home page", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })
        |> get("/")

      assert html_response(conn, 200) =~ "Select CSV file, maximum 100 keywords contained"
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
