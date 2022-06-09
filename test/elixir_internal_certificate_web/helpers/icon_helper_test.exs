defmodule ElixirInternalCertificateWeb.IconHelperTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  import Phoenix.HTML, only: [safe_to_string: 1]

  alias ElixirInternalCertificateWeb.IconHelper

  describe "icon_tag/3" do
    test "when svg icon is available, it should render" do
      first_svg_icon =
        ElixirInternalCertificateWeb.Endpoint
        |> IconHelper.icon_tag("active", class: "customize-icon-class")
        |> safe_to_string()

      second_svg_icon =
        ElixirInternalCertificateWeb.Endpoint
        |> IconHelper.icon_tag("icon-lock")
        |> safe_to_string()

      assert first_svg_icon ==
               "<svg class=\"icon customize-icon-class\"><use xlink:href=\"/images/icon-sprite.svg#icon-priv--static--images--icons--active\"></svg>"

      assert second_svg_icon ==
               "<svg class=\"icon \"><use xlink:href=\"/images/icon-sprite.svg#icon-priv--static--images--icons--icon-lock\"></svg>"
    end
  end
end
