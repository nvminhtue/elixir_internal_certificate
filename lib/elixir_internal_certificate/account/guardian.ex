defmodule ElixirInternalCertificate.Account.Guardian do
  use Guardian, otp_app: :elixir_internal_certificate

  alias ElixirInternalCertificate.Account.Accounts
  alias ElixirInternalCertificate.Account.Schemas.User

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      %User{} = user -> {:ok, user}
      nil -> {:error, :resource_not_found}
    end
  end
end
