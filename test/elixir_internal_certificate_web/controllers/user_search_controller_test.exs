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

  describe "GET /keywords/:id" do
    test "when logged in user click on detail button, returns keyword result", %{conn: conn} do
      user = insert(:user)
      user_search = insert(:user_search, id: 1, user: user)
      insert(:search_result, user_search: user_search)

      conn =
        conn
        |> log_in_user(user)
        |> get("/keywords/#{user_search.id}")

      assert html_response(conn, 200) =~ "Statistics"
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

    # Non existed records will be handled later
  end

  describe "POST /upload" do
    test "when uploading valid file with logged in user, returns home page", %{conn: conn} do
      file = upload_dummy_file("valid.csv")

      conn =
        conn
        |> log_in_user(insert(:user))
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) == "File successfully uploaded. 5 keywords uploaded."
    end

    test "when uploading empty file with logged in user, returns an error of invalid length", %{
      conn: conn
    } do
      file = upload_dummy_file("empty.csv")

      conn =
        conn
        |> log_in_user(insert(:user))
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "Length invalid. 1-1000 keywords within 255 characters only"
    end

    test "when uploading exceed 255 characters file with logged in user, returns an error of invalid length",
         %{conn: conn} do
      file = upload_dummy_file("exceed_char.csv")

      conn =
        conn
        |> log_in_user(insert(:user))
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "Length invalid. 1-1000 keywords within 255 characters only"
    end

    test "when uploading exceed 1000 keywords file with logged in user, returns an error of invalid length",
         %{conn: conn} do
      file = upload_dummy_file("exceed_keyword.csv")

      conn =
        conn
        |> log_in_user(insert(:user))
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "Length invalid. 1-1000 keywords within 255 characters only"
    end

    test "when uploading invalid extension file with logged in user, returns an error of invalid extension",
         %{conn: conn} do
      file = upload_dummy_file("invalid_extension.csve")

      conn =
        conn
        |> log_in_user(insert(:user))
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) == "File extension invalid, csv only"
    end

    test "when uploading valid file but not log in, returns an error", %{conn: conn} do
      file = upload_dummy_file("valid.csv")

      conn =
        conn
        |> post(Routes.user_search_path(conn, :upload), %{
          "file" => file
        })
        |> fetch_flash()

      assert get_session(conn, :user_token) == nil
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end
  end
end
