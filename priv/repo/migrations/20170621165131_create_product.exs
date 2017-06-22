defmodule Telnyx.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :external_product_id, :string
      add :price_in_cents, :integer, null: false, default: 0
      add :product_name, :string, null: false

      timestamps()
    end

  end
end
