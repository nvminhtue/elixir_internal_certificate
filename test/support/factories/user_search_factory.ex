defmodule ElixirInternalCertificate.UserSearchFactory do
  @moduledoc """
    This module defines the user_search factory
    using to generate a valid user_search record
  """
  use ExMachina.Ecto, repo: ElixirInternalCertificate.Repo

  alias ElixirInternalCertificate.Scraper.Schemas.UserSearch

  defmacro __using__(_opts) do
    quote do
      @fixture_path "test/support/assets/files"

      def user_search_factory,
        do: %UserSearch{
          keyword: Faker.Pokemon.name(),
          user: build(:user)
        }

      def valid_user_search_attributes(attrs \\ [%{}], user \\ insert(:user)) do
        Enum.map(
          attrs,
          &Enum.into(&1, %{
            keyword: "keyword",
            user_id: user.id,
            inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
            updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
          })
        )
      end

      def upload_dummy_file(file_path) do
        file_path = Path.join([@fixture_path, file_path])

        %Plug.Upload{
          path: file_path,
          filename: Path.basename(file_path),
          content_type: MIME.from_path(file_path)
        }
      end

      def read_dummy_file(file_path) do
        file_path = Path.join([@fixture_path, file_path])

        File.read!(file_path)
      end
    end
  end
end
