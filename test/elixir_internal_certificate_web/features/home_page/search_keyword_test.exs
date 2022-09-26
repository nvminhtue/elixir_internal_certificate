defmodule ElixirInternalCertificateWeb.HomePage.SearchKeyword do
  use ElixirInternalCertificateWeb.FeatureCase, async: true

  feature("search box component", %{session: session},
    do:
      session
      |> login_user()
      |> assert_has(Query.text("Search"))
      |> assert_has(Query.css("#keyword-search-form"))
  )

  feature "view filled in search item", %{session: session} do
    search_field = Query.text_field("q")
    session
    |> login_user()
    |> fill_in(text_field("q"), with: "keyword")

    find(
      session,
      search_field,
      &assert(
        &1
        |> Wallaby.Element.value()
        |> String.ends_with?("keyword")
      )
    )
  end
end
