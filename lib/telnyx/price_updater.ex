defmodule Telnyx.PriceUpdater do
  alias Telnyx.{Repo, Product}

  def update_prices(:omega_pricing, start_date, end_date) do
    results =
      case Telnyx.OmegaPricingService.fetch_pricing_records(start_date, end_date) do
        {:ok, records} ->
          results =
            Enum.map records, fn pricing_record ->
              ext_pid = "#{pricing_record.id}"

              if product = Repo.get_by(Product, external_product_id: ext_pid) do
                changeset = Product.changeset(product, %{
                              product_name: pricing_record.name,
                              price_in_cents: price_to_cents(pricing_record.price)
                            })
                case changeset.changes do
                  %{product_name: _} ->
                    {
                      :warn,
                      "Omega Pricing update failed for '#{product.product_name} [#{ext_pid}]' due to a name mismatch"}
                  %{price_in_cents: price_in_cents} ->
                    original_price = format_currency(product.price_in_cents)
                    new_price      = format_currency(price_in_cents)

                    product = Product.update_price!(product, price_in_cents)
                    {
                      :ok,
                      "Omega Pricing update succeeded for '#{product.product_name} [#{ext_pid}]' from #{original_price} to #{new_price}"
                    }
                  %{} ->
                    {
                      :noop,
                      "Omega Pricing no change for '#{product.product_name} [#{ext_pid}]'"
                    }
                end
              else
                if !pricing_record.discontinued do
                  changeset =
                    Product.changeset(%Product{}, %{
                      product_name: pricing_record[:product_name],
                      external_pricing_id: ext_pid,
                      price_in_cents: price_to_cents(pricing_record[:price])
                    })
                  case Repo.insert(changeset) do
                    {:ok, product} ->
                      {
                        :ok,
                        "New Product created for '#{product.product_name} [#{product.external_product_id}]'"
                      }
                    {:error, _changeset} ->
                      {
                        :error,
                        "Unable to create Product for [#{ext_pid}]"
                      }
                  end
                end
              end
            end
          {:ok, Enum.filter(results, fn x -> x end)}
        {:error, _} ->
          {:error, []}
      end
  end

  def update_prices(provider, _start_date, _end_date) do
    {:error, "Unknown provider '#{provider}'"}
  end

  defp price_to_cents(price) when is_binary(price) do
    # strip all non-digit, non-decimals
    value = Regex.replace(~r{[^0-9.]}, price, "")
            |> Float.parse()
            |> elem(0)

    round(value * 100.0)
  end

  defp format_currency(price) when is_integer(price) do
    "$#{price / 100}"
  end
end
