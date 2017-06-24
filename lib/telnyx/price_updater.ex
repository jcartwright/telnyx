defmodule Telnyx.PriceUpdater do
  require Logger
  import Number.Currency, only: [number_to_currency: 1]

  alias Telnyx.{Repo, Product}

  def update_prices(:omega_pricing, start_date, end_date) do
    case Telnyx.OmegaPricingService.fetch_pricing_records(start_date, end_date) do
      {:ok, records} ->
        update_prices(records)
      {:error, _} ->
        {:error, []}

    end
  end

  def update_prices(provider, _start_date, _end_date) do
    {:error, "Unknown provider '#{provider}'"}
  end

  defp update_prices(pricing_records) when is_list(pricing_records) do
    results = Enum.map pricing_records, fn pricing_record ->
      ext_pid = "#{pricing_record.id}"

      if product = Repo.get_by(Product, external_product_id: ext_pid) do
        changeset = Product.changeset(product, %{
                      product_name: pricing_record.name,
                      price_in_cents: price_to_cents(pricing_record.price)
                    })
        case changeset.changes do
          %{product_name: _} ->
            msg = "Omega Pricing update failed for '#{product.product_name} [#{ext_pid}]' due to a name mismatch"
            Logger.warn msg
            {:mismatch, msg}
          %{price_in_cents: price_in_cents} ->
            original_price = number_to_currency(product.price_in_cents)
            new_price      = number_to_currency(price_in_cents)

            product = Product.update_price!(product, price_in_cents)
            msg = "Omega Pricing update succeeded for '#{product.product_name} [#{ext_pid}]' from #{original_price} to #{new_price}"
            Logger.info msg
            {:ok, msg}
          %{} ->
            msg = "Omega Pricing no change for '#{product.product_name} [#{ext_pid}]'"
            Logger.info msg
            {:noop, msg}
        end
      else
        if !pricing_record.discontinued do
          changeset =
            Product.changeset(%Product{}, %{
              product_name: pricing_record.name,
              external_product_id: ext_pid,
              price_in_cents: price_to_cents(pricing_record.price)
            })
          case Repo.insert(changeset) do
            {:ok, product} ->
              msg = "New Product created for '#{product.product_name} [#{product.external_product_id}]'"
              Logger.info msg
              {:ok, msg}
            {:error, _changeset} ->
              msg = "Unable to create Product for [#{ext_pid}]"
              Logger.error msg
              {:error, msg}
          end
        end
      end
    end
    {:ok, Enum.filter(results, fn x -> x end)}
  end

  defp price_to_cents(price) when is_binary(price) do
    # strip all non-digit, non-decimals
    value = Regex.replace(~r{[^0-9.]}, price, "")
            |> Float.parse()
            |> elem(0)

    round(value * 100.0)
  end
end
