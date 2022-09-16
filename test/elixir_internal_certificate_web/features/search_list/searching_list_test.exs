defmodule ElixirInternalCertificateWeb.SearchList.SearchingListTest do
  use ElixirInternalCertificateWeb.FeatureCase, async: true

  describe "Visit search list page" do
    feature "with more than 1 page uploaded keywords, renders results list with pagination",
            %{session: session} do
      user = insert(:user)
      insert_list(11, :search_result, user_search: build(:user_search, user: user))

      session
      |> login_user(user)
      |> assert_has(Query.css("table"))
      |> assert_has(Query.css(".pagination-section"))
    end

    feature "with 1 page uploaded keywords, renders results list without pagination",
            %{session: session} do
      user = insert(:user)
      user_search = insert(:user_search, keyword: "dog1", status: :in_progress, id: 1, user: user)
      insert(:search_result, user_search: user_search)

      session
      |> login_user(user)
      |> assert_has(Query.css("table"))
      |> assert_has(Query.css(".align-middle"))
      |> refute_has(Query.css(".pagination-section"))
    end

    feature "with no uploaded keyword, renders a blank table", %{
      session: session
    } do
      session
      |> login_user()
      |> assert_has(Query.css("table"))
      |> refute_has(Query.css(".align-middle"))
      |> refute_has(Query.css(".pagination-section"))
    end

    feature "with success user_search, renders enable detail button", %{session: session} do
      user = insert(:user)
      insert(:user_search, keyword: "dog1", status: :success, id: 1, user: user)

      session
      |> login_user(user)
      |> assert_has(Query.text(Query.css(".btn.btn-primary.btn-block"), "Click for detail"))
    end

    feature "with unsuccess user_search, renders disable detail button", %{session: session} do
      user = insert(:user)
      insert(:user_search, keyword: "dog1", status: :pending, id: 1, user: user)

      session
      |> login_user(user)
      |> assert_has(Query.css(".btn.btn-primary.btn-block.disabled"))
    end

    feature "when click on nimble logo, returns home page", %{session: session} do
      session =
        session
        |> login_user()
        |> click(Query.text("Select CSV file, maximum 1000 keywords contained"))

      assert current_path(session) ==
               Routes.user_search_path(ElixirInternalCertificateWeb.Endpoint, :index)
    end
  end

  describe "Visit search detail page" do
    feature "when click on detail button, renders result info", %{session: session} do
      user = insert(:user)
      user_search = insert(:user_search, keyword: "dog1", status: :success, id: 1, user: user)
      insert(:search_result, user_search: user_search)

      session
      |> login_user(user)
      |> click(button("Click for detail"))
      |> assert_has(Query.css("h1", text: "Statistics"))
      |> assert_has(Query.css("h1", text: "List of top adword links"))
      |> assert_has(Query.css("h1", text: "List of non adword links"))
    end

    feature "when click on html show button on result info, renders html response", %{session: session} do
      user = insert(:user)
      user_search = insert(:user_search, keyword: "dog1", status: :success, id: 1, user: user)
      insert(:search_result, user_search: user_search)

      session =
        session
        |> login_user(user)
        |> click(button("Click for detail"))
        |> click(button("Show"))

      assert page_source(session) =~ "<html"
    end
  end
end
