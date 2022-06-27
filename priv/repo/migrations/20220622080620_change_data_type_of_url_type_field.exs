defmodule ElixirInternalCertificate.Repo.Migrations.ChangeDataTypeOfUrlTypeField do
  use Ecto.Migration

  def up do
    alter table(:url_results) do
      modify :type, :string, nullable: false, default: "non_ad_word"
    end
  end

  def down do
    execute """
      alter table url_results alter column type type integer using (type::integer);
    """
  end
end
