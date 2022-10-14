defmodule ElixirInternalCertificate.Repo.Migrations.DropUrlResults do
  use Ecto.Migration

  def change do
    drop index(:url_results, [:url, :type])

    drop table(:url_results)
  end
end
