defmodule Telnyx.OmegaPricingServiceTest do
  use ExUnit.Case
  use Timex

  import Telnyx.OmegaPricingService
  @config  Application.get_env(:telnyx, Telnyx.OmegaPricingService)

  describe "pricing_service_url/2" do
    test "builds the expected url" do
      start_date = Timex.shift(Timex.today, months: -1)
      end_date   = Timex.today

      expected = @config[:endpoint] <> "pricing/records.json?" <>
        URI.encode_query(%{
          api_key:    @config[:api_key],
          start_date: start_date,
          end_date:   end_date
        })

      assert pricing_service_url(start_date, end_date) == expected
    end
  end

  describe "fetch_pricing_records/0" do
    # TODO: consider Bypass for controlling the HTTP request/response in test
    # see: https://github.com/pspdfkit-labs/bypass
    test "returns pricing records" do
      assert {:ok, records} = fetch_pricing_records()
      refute Enum.empty?(records)
    end

    test "converts raw records to omega pricing records" do
      {:ok, records} = fetch_pricing_records()
      assert %Telnyx.OmegaPricingRecord{} = List.first(records)
    end
  end

  describe "fetch_pricing_records/2" do
    test "accepts start and end date params" do
      start_date = Timex.shift(Timex.today, months: -1)
      end_date   = Timex.today

      assert {:ok, records} = fetch_pricing_records(start_date, end_date)
      refute Enum.empty?(records)
    end
  end
end
