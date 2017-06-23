defmodule Telnyx.OmegaPricingServiceTest do
  use ExUnit.Case
  use Timex

  import Telnyx.OmegaPricingService
  @config  Application.get_env(:telnyx, Telnyx.OmegaPricingService)

  describe "pricing_service_url/0" do
    test "builds the expected url" do
      expected = @config[:endpoint] <> "pricing/records.json?" <>
        URI.encode_query(%{
          api_key:    @config[:api_key],
          start_date: Timex.today,
          end_date:   Timex.shift(Timex.today, months: -1)
        })

      assert pricing_service_url() == expected
    end
  end

  describe "fetch_pricing_records/0" do
    # TODO: consider Bypass for controlling the HTTP request/response in test
    # see: https://github.com/pspdfkit-labs/bypass
    test "returns pricing records" do
      assert {:ok, records} = fetch_pricing_records()
      assert Enum.count(records) == 2
    end
  end
end
