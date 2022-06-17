defmodule ElixirInternalCertificate.Factory do
  use ExMachina.Ecto, repo: ElixirInternalCertificate.Repo

  # Define your factories in /test/factories and declare it here,
  # eg: `use ElixirInternalCertificate.Account.Accounts.UserFactory`

  use ElixirInternalCertificate.{UserFactory, UserTokenFactory, UserSearchFactory}
end
