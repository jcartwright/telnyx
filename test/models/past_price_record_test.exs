defmodule Telnyx.PastPriceRecordTest do
  use Telnyx.ModelCase

  alias Telnyx.PastPriceRecord

  @valid_attrs %{percentage_change: "120.5", price_in_cents: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PastPriceRecord.changeset(%PastPriceRecord{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PastPriceRecord.changeset(%PastPriceRecord{}, @invalid_attrs)
    refute changeset.valid?
  end
end
