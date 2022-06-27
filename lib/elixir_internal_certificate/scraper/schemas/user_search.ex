defmodule ElixirInternalCertificate.Scraper.Schemas.UserSearch do
  use Ecto.Schema

  import Ecto.Changeset, only: [change: 2]

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

  def status_changeset(searching_keyword, status),
    do: change(searching_keyword, status: status)
end
