defmodule ElixirInternalCertificate.Repo.Migrations.CreateUserSearches do
  use Ecto.Migration

  def change do
    create table(:user_searches) do
      add :keyword, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:user_searches, [:user_id])
    create index(:user_searches, [:keyword])
    create index(:user_searches, [:status])
  end
end
