defmodule ElixirInternalCertificateWeb.HomePage.AuthenticationTest do
  use ElixirInternalCertificateWeb.FeatureCase, async: true

  feature "when unauthenticated, renders login page", %{session: session} do
    visit(session, Routes.user_search_path(ElixirInternalCertificateWeb.Endpoint, :index))

    assert current_path(session) ==
             Routes.user_session_path(ElixirInternalCertificateWeb.Endpoint, :new)

    assert_has(session, Query.css(".btn.btn-primary.btn-block.mb-4", text: "Login"))
  end

  feature "when authenticated, renders home page", %{session: session} do
    user = insert(:user)

    logged_in_session = login_user(session, user)

    assert current_path(logged_in_session) ==
             Routes.user_search_path(ElixirInternalCertificateWeb.Endpoint, :index)

    logged_in_session
    |> assert_has(Query.css(".btn.disabled", text: "Hello, #{user.email}"))
    |> assert_has(Query.css(".btn", text: "Log out"))
  end
end
