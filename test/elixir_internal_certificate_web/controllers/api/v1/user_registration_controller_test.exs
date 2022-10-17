defmodule ElixirInternalCertificateWeb.Api.V1.UserRegistrationControllerTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  describe "new/2" do
    test "given valid email and password, returns status 200", %{conn: conn} do
      conn = post(conn, Routes.api_user_registration_path(conn, :create), valid_user_attributes())

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => _,
                   "password" => nil
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "user_auth"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given an existing email and valid password, returns status 400", %{conn: conn} do
      insert(:user, email: "existing@mail.com")

      conn =
        post(conn, Routes.api_user_registration_path(conn, :create), %{
          email: "existing@mail.com",
          password: valid_user_password()
        })

      assert json_response(conn, 400) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "message" => "Invalid email or password"
                 }
               ]
             }
    end

    test "given a blank email and blank password, returns status 400", %{conn: conn} do
      conn =
        post(conn, Routes.api_user_registration_path(conn, :create), %{
          email: "",
          password: ""
        })

      assert json_response(conn, 400) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "message" => "Invalid email or password"
                 }
               ]
             }
    end
  end
end
