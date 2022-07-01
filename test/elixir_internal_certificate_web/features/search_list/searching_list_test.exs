defmodule ElixirInternalCertificateWeb.SearchList.SearchingListTest do
  use ElixirInternalCertificateWeb.FeatureCase, async: true

  # No result case will be added later on.
  feature "when visit home page with uploaded keyword, renders results list", %{session: session} do
    session
    |> login_user()
    |> assert_has(Query.css("table"))
  end

  feature "when click on detail button, renders result info", %{session: session} do
    session
    |> login_user()
    |> click(css(".align-middle:first-child button"))
    |> assert_has(Query.css("h1", text: "Statistics"))
    |> assert_has(Query.css("h1", text: "List of top adword links"))
    |> assert_has(Query.css("h1", text: "List of non adword links"))
  end

  feature "when click on html show button, renders html response", %{session: session} do
    session =
      session
      |> login_user()
      |> click(css(".align-middle:first-child button"))
      |> click(button("Show"))

    assert page_source(session) =~ "<html"
  end

  feature "when click on nimble logo, returns home page", %{session: session} do
    session =
      session
      |> login_user()
      |> click(css(".align-middle:first-child button"))
      |> click(css(".navbar-brand.mt-2.mt-lg-0"))

    assert current_path(session) ==
             Routes.user_search_path(ElixirInternalCertificateWeb.Endpoint, :index)
  end
end
