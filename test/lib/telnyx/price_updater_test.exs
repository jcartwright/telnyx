defmodule Telnyx.PriceUpdaterTest do
  use Telnyx.ServiceCase
  use Timex

  import Telnyx.PriceUpdater

  describe "update_prices/3" do
    setup config do
      if dispositions = config[:dispositions] do
        products = cond do
          is_atom(dispositions) ->
            create_product_with_disposition(dispositions)
          is_list(dispositions) ->
            Enum.map dispositions, fn disposition ->
              create_product_with_disposition(disposition)
            end
          true -> []
        end

        start_date = Timex.shift(Timex.today, months: -1)
        end_date   = Timex.today

        {:ok, products: products, start_date: start_date, end_date: end_date}
      else
        :ok
      end
    end

    test "unknown provider returns an error" do
      assert {:error, message} = update_prices(:foobar, nil, nil)
      assert message =~ ~r/Unknown provider 'foobar'/
    end

    @tag dispositions: [:noop, :mismatch, :update]
    test "returns results when successful", %{start_date: start_date, end_date: end_date} do
      assert {:ok, results} = update_prices(:omega_pricing, start_date, end_date)
      refute Enum.empty?(results)
    end

    @tag dispositions: :noop
    test "returns disposition {:noop, ...} for products with no changes", %{start_date: start_date, end_date: end_date} do
      assert {:ok, results} = update_prices(:omega_pricing, start_date, end_date)
      assert {:noop, msg} =
        results
        |> Enum.find(&(elem(&1, 0) == :noop))
      assert msg =~ ~r/no change for/
    end

    @tag dispositions: :mismatch
    test "returns result {:mismatch, msg} for mismatched products", %{start_date: start_date, end_date: end_date} do
      assert {:ok, results} = update_prices(:omega_pricing, start_date, end_date)
      assert {:mismatch, msg} =
        results
        |> Enum.find(&(elem(&1, 0) == :mismatch))
      assert msg =~ ~r/name mismatch/
    end

    @tag dispositions: [:noop, :update]
    test "returns result {:ok, msg} for updated products", %{start_date: start_date, end_date: end_date} do
      assert {:ok, results} = update_prices(:omega_pricing, start_date, end_date)
      assert {:ok, msg} =
        results
        |> Enum.find(&(elem(&1, 0) == :ok))
      assert msg =~ ~r/update succeeded/
    end

    @tag dispositions: :update
    test "creates past pricing records for updated products", %{start_date: start_date, end_date: end_date} do
      assert {:ok, _} = update_prices(:omega_pricing, start_date, end_date)
      product = Repo.get_by(Telnyx.Product, external_product_id: "update")
                |> Repo.preload(:past_price_records)
      refute Enum.empty?(product.past_price_records)
    end
  end
end
