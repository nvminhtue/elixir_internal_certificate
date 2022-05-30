defmodule ElixirInternalCertificateWeb.ReadinessRequestTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  test "returns 200", %{conn: conn} do
    conn =
      get(
        conn,
        "#{Application.get_env(:elixir_internal_certificate, ElixirInternalCertificateWeb.Endpoint)[:health_path]}/readiness"
      )

    assert response(conn, :ok) =~ "ready"
  end
end
