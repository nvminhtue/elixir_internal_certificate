defmodule ElixirInternalCertificate.Repo.Migrations.ChangeDataTypeOfUrlTypeField do
  use Ecto.Migration

  def change do
    alter table(:url_results) do
      modify :type, :string, nullable: false, default: "non_ad_word"
    end
  end
end
