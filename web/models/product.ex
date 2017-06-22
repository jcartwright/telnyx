defmodule Telnyx.Product do
  use Telnyx.Web, :model

  schema "products" do
    field :external_product_id, :string
    field :price_in_cents, :integer
    field :product_name, :string
    has_many :past_price_records, Telnyx.PastPriceRecord

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:external_product_id, :price_in_cents, :product_name])
    |> validate_required([:external_product_id, :price_in_cents, :product_name])
  end
end
