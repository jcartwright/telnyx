defmodule Telnyx.OmegaPricingRecordTest do
  use ExUnit.Case, async: true

  alias Telnyx.OmegaPricingRecord

  test "has fields with expected default values" do
    record = %OmegaPricingRecord{}
    assert nil == record.id
    assert "" == record.name
    assert "" == record.price
    assert "" == record.category
    assert false == record.discontinued
  end
end
