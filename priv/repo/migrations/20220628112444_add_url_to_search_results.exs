defmodule ElixirInternalCertificate.Repo.Migrations.AddUrlToSearchResults do
  use Ecto.Migration

  def change do
    alter table(:search_results) do
      add :non_ad_words_links, {:array, :string}, default: []
      add :top_ad_words_links, {:array, :string}, default: []
    end
  end
end
