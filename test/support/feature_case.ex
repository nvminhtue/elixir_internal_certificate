defmodule ElixirInternalCertificateWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
      use Wallaby.Feature
      use Mimic

      import ElixirInternalCertificate.Factory
      import ElixirInternalCertificateWeb.Gettext
      import Wallaby.Query, only: [text_field: 1, button: 1, css: 2]

      alias ElixirInternalCertificate.Repo
      alias ElixirInternalCertificateWeb.Endpoint
      alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

      @moduletag :feature_test

      def login_user(session, user \\ insert(:user)),
        do:
          session
          |> visit(Routes.user_session_path(Endpoint, :new))
          |> fill_in_login_form(user)

      defp fill_in_login_form(session, user),
        do:
          session
          |> fill_in(text_field("user[email]"), with: user.email)
          |> fill_in(text_field("user[password]"), with: valid_user_password())
          |> click(button("Login"))
    end
  end
end
