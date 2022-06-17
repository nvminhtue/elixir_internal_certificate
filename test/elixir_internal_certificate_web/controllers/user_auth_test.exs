defmodule ElixirInternalCertificateWeb.UserAuthTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificateWeb.UserAuth

  @remember_me_cookie "_elixir_internal_certificate_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(
        :secret_key_base,
        ElixirInternalCertificateWeb.Endpoint.config(:secret_key_base)
      )
      |> init_test_session(%{})

    %{conn: conn}
  end

  describe "log_in_user/3" do
    test "when log_in_user calls success, stores the user token in the session",
         %{conn: conn} do
      user = insert(:user)
      conn = conn |> fetch_flash() |> UserAuth.log_in_user(user)

      assert token = get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(token)
      assert get_flash(conn, :info) == "Welcome back #{user.email}"
    end

    test "when log_in_user calls success, clears everything previously stored in the session",
         %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> put_session(:to_be_removed, "value")
        |> fetch_flash()
        |> UserAuth.log_in_user(user)

      assert get_session(conn, :to_be_removed) == nil
      assert get_flash(conn, :info) == "Welcome back #{user.email}"
    end

    test "when log_in_user calls success, redirects to the configured path",
         %{conn: conn} do
      conn =
        conn
        |> put_session(:user_return_to, "/hello")
        |> fetch_flash()
        |> UserAuth.log_in_user(insert(:user))

      assert redirected_to(conn) == "/hello"
    end

    test "when log_in_user calls success, writes a cookie if remember_me is configured",
         %{conn: conn} do
      conn =
        conn
        |> fetch_cookies()
        |> fetch_flash()
        |> UserAuth.log_in_user(insert(:user), %{"remember_me" => "true"})

      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]
      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_user/1" do
    test "when logout_user calls success, erases session and cookies", %{conn: conn} do
      user_token = Accounts.generate_user_session_token(insert(:user))

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> put_req_cookie(@remember_me_cookie, user_token)
        |> fetch_cookies()
        |> UserAuth.log_out_user()

      assert get_session(conn, :user_token) == nil
      assert conn.cookies[@remember_me_cookie] == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(user_token) == nil
    end

    test "when logout_user calls success, works even if user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UserAuth.log_out_user()

      assert get_session(conn, :user_token) == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_user/2" do
    test "when fetch_current_user/2 calls success, authenticates user from session will be fetch",
         %{conn: conn} do
      user = insert(:user)
      user_token = Accounts.generate_user_session_token(user)

      conn = conn |> put_session(:user_token, user_token) |> UserAuth.fetch_current_user([])

      assert conn.assigns.current_user.id == user.id
    end

    test "when fetch_current_user/2 calls success, authenticates user from cookies will be fetched",
         %{conn: conn} do
      user = insert(:user)

      logged_in_conn =
        conn
        |> fetch_cookies()
        |> fetch_flash()
        |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

      user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UserAuth.fetch_current_user([])

      assert get_session(conn, :user_token) == user_token
      assert conn.assigns.current_user.id == user.id
    end

    test "when data is missing, does not authenticate", %{conn: conn} do
      _ = Accounts.generate_user_session_token(insert(:user))

      conn = UserAuth.fetch_current_user(conn, [])

      assert get_session(conn, :user_token) == nil
      assert conn.assigns.current_user == nil
    end
  end

  describe "redirect_if_user_is_authenticated/2" do
    test "when user is authenticated, redirects to default page", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, insert(:user))
        |> UserAuth.redirect_if_user_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "when user is not authenticated, does not redirect", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_authenticated(conn, [])

      assert conn.halted == false
      assert conn.status == nil
    end
  end

  describe "require_authenticated_user/2" do
    test "when user is not authenticated, redirects to login page", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])

      assert conn.halted
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "when user is authenticated from previous path, stores the path to redirect to on GET",
         %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn_baz =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_baz.halted
      assert get_session(halted_conn_baz, :user_return_to) == "/foo?bar=baz"

      halted_conn_bar =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_bar.halted
      assert get_session(halted_conn_bar, :user_return_to) == nil
    end

    test "when user is not authenticated, does not redirect", %{conn: conn} do
      conn = conn |> assign(:current_user, insert(:user)) |> UserAuth.require_authenticated_user([])

      assert conn.halted == false
      assert conn.status == nil
    end
  end
end
