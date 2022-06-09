defmodule ElixirInternalCertificate.UserTokenFactory do
  @moduledoc """
    This module defines the user_token factory
    using to generate a valid user_token record
  """
  use ExMachina.Ecto, repo: ElixirInternalCertificate.Repo

  alias ElixirInternalCertificate.Account.Schemas.UserToken

  defmacro __using__(_opts) do
    quote do
      def user_token_factory do
        %UserToken{
          token: Faker.Pokemon.name(),
          context: "session",
          user: build(:user)
        }
      end
    end
  end
end
