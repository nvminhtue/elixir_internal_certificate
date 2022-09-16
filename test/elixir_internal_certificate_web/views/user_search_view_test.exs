defmodule ElixirInternalCertificateWeb.UserSearchViewTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificateWeb.UserSearchView

  describe "is_active_page/2" do
    test "with the same page and target, returns active status",
      do: assert(UserSearchView.is_active_page?(1, 1) == "active")

    test "with the different page and target, returns blank status",
      do: assert(UserSearchView.is_active_page?(1, 2) == "")

    test "with the nil target, returns nil status",
      do: assert(UserSearchView.is_active_page?(1, nil) == nil)
  end
end
