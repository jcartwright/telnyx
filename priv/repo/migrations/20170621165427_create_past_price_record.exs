defmodule Telnyx.Repo.Migrations.CreatePastPriceRecord do
  use Ecto.Migration

  def change do
    create table(:past_price_records) do
      add :price_in_cents, :integer, null: false
      add :percentage_change, :float
      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end
    create index(:past_price_records, [:product_id])

  end
end
