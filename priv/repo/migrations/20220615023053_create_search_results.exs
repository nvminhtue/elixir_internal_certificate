defmodule ElixirInternalCertificate.Repo.Migrations.CreateSearchResults do
  use Ecto.Migration

  def change do
    create table(:search_results) do
      add :top_ad_words_total, :integer
      add :ad_words_total, :integer
      add :non_ad_words_total, :integer
      add :links_total, :integer
      add :preview, :text
      add :user_search_id, references(:user_searches, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:search_results, [:user_search_id])
  end
end
