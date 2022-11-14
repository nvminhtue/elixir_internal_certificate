defmodule ElixirInternalCertificateWeb.Api.V1.UserSessionControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificate.Account.Guardian

  describe "POST create/2" do
    test "given valid user credentials, returns access token", %{conn: conn} do
      email = "test@test.com"
      insert(:user, email: email)

      conn =
        post(conn, Routes.api_user_session_path(conn, :create), %{
          email: email,
          password: valid_user_password()
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => ^email,
                   "token" => _
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "user_session"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given invalid user credentials, returns error response", %{conn: conn} do
      email = "test@test.com"
      insert(:user, email: email)

      conn =
        post(conn, Routes.api_user_session_path(conn, :create), %{
          email: "test@gmail.com",
          password: "invalid_password"
        })

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => "Invalid email or password"
                 }
               ]
             }
    end

    test "given invalid request params, returns error response", %{conn: conn} do
      conn =
        post(conn, Routes.api_user_session_path(conn, :create), %{
          not_valid: "not_valid"
        })

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => "Email or password is missing"
                 }
               ]
             }
    end

    test "given valid user credentials, gets error when encode_and_sign, returns error", %{
      conn: conn
    } do
      email = "test@test.com"
      insert(:user, email: email)

      stub(Guardian, :encode_and_sign, fn _, _ -> :stub end)

      conn =
        post(conn, Routes.api_user_session_path(conn, :create), %{
          email: email,
          password: valid_user_password()
        })

      assert json_response(conn, 500) == %{
               "errors" => [
                 %{
                   "code" => "internal_server_error",
                   "detail" => "Internal server error"
                 }
               ]
             }
    end
  end
end
