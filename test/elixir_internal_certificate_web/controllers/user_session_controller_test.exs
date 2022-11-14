defmodule ElixirInternalCertificateWeb.UserSessionControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET /users/log_in" do
    test "when redirect to login page, it should render", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))

      response = html_response(conn, 200)

      assert response =~ "<h1>Login</h1>"
      assert response =~ "Register</a>"
    end

    test "with already logged in, it should redirect", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(Routes.user_session_path(conn, :new))

      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/log_in" do
    test "with valid email and password, logs the user in", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })
        |> get("/keywords")

      assert get_session(conn, :user_token)

      # Now do a logged in request and assert on the menu
      logged_conn = get(conn, "/keywords")
      response = html_response(logged_conn, 200)

      assert response =~ user.email
      assert response =~ "Log out</a>"
    end

    test "with valid email and password, logs the user in with remember me", %{
      conn: conn
    } do
      user = insert(:user)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_elixir_internal_certificate_web_user_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "with valid email and password, logs the user in with return to", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "with invalid credentials, emits error message", %{conn: conn} do
      user = insert(:user)

      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Login</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "when log the logged-in-user out, it should be successful", %{conn: conn} do
      user = insert(:user)
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))

      assert redirected_to(conn) == "/users/log_in"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "when the user is not logged in, succeeds ", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))

      assert redirected_to(conn) == "/users/log_in"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
