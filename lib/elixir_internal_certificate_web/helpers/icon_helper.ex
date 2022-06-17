defmodule ElixirInternalCertificateWeb.IconHelper do
  @moduledoc """
  Generate the SVG icon tag
  """

  use Phoenix.HTML

  alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

  @svg_shape_id_prefix "icon-priv--static--images--icons--"

  def icon_tag(conn, icon_file_name, opts \\ []) do
    classes = "icon " <> Keyword.get(opts, :class, "")

    content_tag(:svg, class: classes) do
      tag(:use,
        "xlink:href":
          Routes.static_path(
            conn,
            "/images/icon-sprite.svg#" <> @svg_shape_id_prefix <> icon_file_name
          )
      )
    end
  end
end
