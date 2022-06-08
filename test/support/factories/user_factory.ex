defmodule ElixirInternalCertificate.UserFactory do
  @moduledoc """
    This module defines the user factory
    using to generate a valid user record
  """
  use ExMachina.Ecto, repo: ElixirInternalCertificate.Repo

  alias ElixirInternalCertificate.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          email: unique_user_email(),
          hashed_password: Bcrypt.hash_pwd_salt(valid_user_password())
        }
      end

      def valid_user_password, do: "hello world!"

      def unique_user_email, do: Faker.Internet.email()

      def valid_user_attributes(attrs \\ %{}) do
        Enum.into(attrs, %{
          email: unique_user_email(),
          password: valid_user_password()
        })
      end
    end
  end
end
