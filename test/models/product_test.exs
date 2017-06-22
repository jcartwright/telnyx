defmodule Telnyx.ProductTest do
  use Telnyx.ModelCase

  alias Telnyx.Product

  @valid_attrs %{external_product_id: "some content", price_in_cents: 42, product_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs)
    refute changeset.valid?
  end
end
