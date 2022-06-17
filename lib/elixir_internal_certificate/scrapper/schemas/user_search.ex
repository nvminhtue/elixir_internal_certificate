defmodule ElixirInternalCertificate.Scrapper.Schemas.UserSearch do
  use Ecto.Schema

  schema "user_searches" do
    field :keyword, :string

    field :status,
          Ecto.Enum,
          values: [:pending, :inprogress, :failed, :success],
          default: :pending

    has_many :search_results,
             ElixirInternalCertificate.Scrapper.Schemas.SearchResult,
             foreign_key: :user_search_id

    belongs_to :user,
               ElixirInternalCertificate.Account.Schemas.User,
               foreign_key: :user_id

    timestamps()
  end
end
