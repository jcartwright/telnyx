defmodule Telnyx.Product do
  use Telnyx.Web, :model
  alias Telnyx.{Repo, Product, PastPriceRecord}

  schema "products" do
    field :external_product_id, :string
    field :price_in_cents, :integer
    field :product_name, :string
    has_many :past_price_records, Telnyx.PastPriceRecord

    timestamps()
  end

  def update_price!(product, price) when is_integer(price) and price >= 0 do
    current_price = product.price_in_cents
    new_price = price

    cond do
      current_price == new_price ->
        product
      true ->
        price_changeset = 
          %PastPriceRecord{}
          |> PastPriceRecord.changeset(
              %{
                price_in_cents: current_price,
                percentage_change: calculate_percentage_change(current_price, new_price)
              })

        product_changeset = 
          product
          |> Repo.preload(:past_price_records)
          |> Product.price_update_changeset(%{price_in_cents: new_price})
          |> Ecto.Changeset.put_assoc(:past_price_records, [price_changeset])
          |> Repo.update!()
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:external_product_id, :price_in_cents, :product_name])
    |> validate_required([:external_product_id, :price_in_cents, :product_name])
  end

  @doc """
  Builds a price update changeset based on the `struct` and `params`, only
  when the price_in_cents is different from the current value.
  """
  def price_update_changeset(struct, %{price_in_cents: price_in_cents} = params)
    when is_integer(price_in_cents) and price_in_cents >= 0 do
    struct
    |> cast(params, [:price_in_cents])
    |> validate_required([:price_in_cents])
  end

  defp calculate_percentage_change(original_price, new_price)
    when is_integer(original_price) and is_integer(new_price),
    do: ((new_price - original_price) / new_price) * 100
end
