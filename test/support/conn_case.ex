defmodule ElixirInternalCertificateWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ElixirInternalCertificateWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias ElixirInternalCertificate.Account.Accounts
  alias ElixirInternalCertificate.Account.Guardian

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

      use Mimic

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.View
      import ElixirInternalCertificateWeb.ConnCase
      import ElixirInternalCertificate.Factory

      alias ElixirInternalCertificate.Account.Accounts
      alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ElixirInternalCertificateWeb.Endpoint
    end
  end

  setup tags do
    pid = Sandbox.start_owner!(ElixirInternalCertificate.Repo, shared: not tags[:async])
    on_exit(fn -> Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def token_auth_user(%Plug.Conn{} = conn, user) do
    Guardian.Plug.sign_in(conn, user)
  end
end
