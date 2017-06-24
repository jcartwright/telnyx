defmodule Telnyx.TestHelpers do
  alias Telnyx.{Repo, Product}

  @default_product_attrs %{
    external_product_id: "test-product",
    product_name: "Test Product",
    price_in_cents: 1_00
  }

  @noop_product_attrs %{
    external_product_id: "noop",
    product_name: "No-Op Product",
    price_in_cents: 1_00
  }

  @mismatch_product_attrs %{
    external_product_id: "mismatch",
    product_name: "Mismatch Product",
    price_in_cents: 1_00
  }

  @update_product_attrs %{
    external_product_id: "update",
    product_name: "Update Product",
    price_in_cents: 1_00
  }

  def insert_product(attrs \\ %{}) do
    # merge defaults with provided attrs
    changes =
      attrs
      |> Enum.into(@default_product_attrs)

    %Product{}
    |> Product.changeset(changes)
    |> Repo.insert!()
  end

  def create_product_with_disposition(disposition) when is_atom(disposition) do
    case disposition do
      :noop ->
        insert_product(@noop_product_attrs)
      :mismatch ->
        insert_product(@mismatch_product_attrs)
      :update ->
        insert_product(@update_product_attrs)
    end
  end
end
