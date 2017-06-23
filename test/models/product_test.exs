defmodule Telnyx.ProductTest do
  use Telnyx.ModelCase

  alias Telnyx.{Repo, Product, PastPriceRecord}

  @valid_attrs %{external_product_id: "AWv123", price_in_cents: 10000, product_name: "Acme Widget v1.2.3"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "price_update_changeset/2 with price change is valid"  do
    price_change_attrs = %{price_in_cents: 4301}
    changeset = Product.price_update_changeset(%Product{}, price_change_attrs)
    assert changeset.valid?
    assert %{price_in_cents: _} = changeset.changes
  end

  describe "update_price!/2" do
    setup do
      product =
        %Product{}
        |> Product.changeset(@valid_attrs)
        |> Repo.insert!()

      {:ok, product: product}
    end

    test "with no price change does not create a past_price_record", %{product: product} do
      product =
        product
        |> Product.update_price!(product.price_in_cents)
        |> Repo.preload(:past_price_records)

      assert Enum.empty?(product.past_price_records)
    end

    test "with a price change updates product's price", %{product: product} do
      original_price = product.price_in_cents
      new_price = original_price + 1000

      product = Product.update_price!(product, new_price)
      assert new_price == product.price_in_cents
    end

    test "with price change creates a past_price_record on update", %{product: product} do
      product =
        product
        |> Product.update_price!(product.price_in_cents + 1000)
        |> Repo.preload(:past_price_records)

      refute Enum.empty?(product.past_price_records)
    end

    test "with price change archives the percentage_change", %{product: product} do
      product =
        product
        |> Product.update_price!(product.price_in_cents + 1100)
        |> Repo.preload(:past_price_records)

      %PastPriceRecord{percentage_change: percentage_change}  =
        product.past_price_records
        |> List.last()

      assert 10.0 == Float.round(percentage_change)
    end

    test "with price change archives the original price", %{product: product} do
      original_price = product.price_in_cents

      product =
        product
        |> Product.update_price!(original_price + 1100)
        |> Repo.preload(:past_price_records)

      assert %PastPriceRecord{price_in_cents: ^original_price} =
        product.past_price_records
        |> List.last()
    end

    test "with a negative price, raises an exception", %{product: product} do
      assert_raise FunctionClauseError, ~r/no function clause matching/, fn ->
        product |> Product.update_price!(-100)
      end
    end
  end
end
