defmodule ElixirInternalCertificate.Repo.Migrations.CreateUrlResults do
  use Ecto.Migration

  def change do
    create table(:url_results) do
      add :url, :string, null: false
      add :type, :integer, null: false
      add :search_result_id, references(:search_results, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:url_results, [:url, :type])
  end
end
