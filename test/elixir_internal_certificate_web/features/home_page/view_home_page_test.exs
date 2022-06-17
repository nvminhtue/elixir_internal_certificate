defmodule ElixirInternalCertificateWeb.HomePage.ViewHomePageTest do
  use ElixirInternalCertificateWeb.FeatureCase

  feature "view home page", %{session: session} do
    visit(session, Routes.page_path(ElixirInternalCertificateWeb.Endpoint, :index))

    assert_has(session, Query.text("Welcome to Phoenix!"))
  end
end
