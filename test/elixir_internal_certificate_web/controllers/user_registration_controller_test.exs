defmodule ElixirInternalCertificateWeb.UserRegistrationControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "GET /users/register" do
    test "when visit registration page, it should be rendered", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))

      response = html_response(conn, 200)

      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "when already logged in, it should redirect", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(Routes.user_registration_path(conn, :new))

      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "when successfully create new account, logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => valid_user_attributes(email: email)
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      logged_conn = get(conn, "/")

      response = html_response(logged_conn, 200)

      assert response =~ email
      assert response =~ "Log out</a>"
    end

    test "When invalid data, render errors", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "short"}
        })

      response = html_response(conn, 200)

      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 6 character"
    end
  end
end
