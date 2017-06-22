defmodule Telnyx.PastPriceRecord do
  use Telnyx.Web, :model

  schema "past_price_records" do
    field :price_in_cents, :integer
    field :percentage_change, :float
    belongs_to :product, Telnyx.Product

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:price_in_cents, :percentage_change])
    |> validate_required([:price_in_cents, :percentage_change])
  end
end
