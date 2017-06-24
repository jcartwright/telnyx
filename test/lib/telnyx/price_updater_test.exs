defmodule Telnyx.PriceUpdaterTest do
  use ExUnit.Case
  use Timex

  import Telnyx.PriceUpdater

  describe "update_prices/3" do

    test "unknown provider returns an error" do
      assert {:error, message} = update_prices(:foobar, nil, nil)
      assert message =~ ~r/Unknown provider 'foobar'/
    end

    test "returns results when successful" do
      start_date = Timex.shift(Timex.today, months: -1)
      end_date   = Timex.today

      assert {:ok, results} = update_prices(:omega_pricing, start_date, end_date)
    end
  end
end
