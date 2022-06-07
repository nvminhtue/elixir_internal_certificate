defmodule ElixirInternalCertificateWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
      use Wallaby.Feature
      use Mimic

      import ElixirInternalCertificate.Factory
      import ElixirInternalCertificateWeb.Gettext

      alias ElixirInternalCertificate.Repo
      alias ElixirInternalCertificateWeb.Endpoint
      alias ElixirInternalCertificateWeb.Router.Helpers, as: Routes

      @moduletag :feature_test
    end
  end
end
