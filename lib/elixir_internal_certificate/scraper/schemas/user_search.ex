defmodule ElixirInternalCertificate.Scraper.Schemas.UserSearch do
  use Ecto.Schema

  alias ElixirInternalCertificate.Account.Schemas.User
  alias ElixirInternalCertificate.Scraper.Schemas.SearchResult

  schema "user_searches" do
    field :keyword, :string

    field :status,
          Ecto.Enum,
          values: [:pending, :in_progress, :failed, :success],
          default: :pending

    has_many :search_results, SearchResult

    belongs_to :user, User

    timestamps()
  end
end
