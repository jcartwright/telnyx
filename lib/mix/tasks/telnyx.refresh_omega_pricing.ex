defmodule Mix.Tasks.Telnyx.RefreshOmegaPricing do
  use Mix.Task
  require Logger

  import Mix.Ecto

  alias Telnyx.{Repo, Product, PastPriceRecord}

  @shortdoc "Refresh the `products` table with Omega Pricing information"
  def run(args) do
    repos = parse_repo(args)

    {:ok, records} = Telnyx.OmegaPricingService.fetch_pricing_records
    if Enum.any?(records) do
      # We have to manually ensure the Ecto.Repo is started since we're
      # unsupervised in Mix.Task land...
      Enum.each repos, fn repo ->
        ensure_repo(repo, args)
        ensure_started(repo, [])

        Enum.each records, fn pricing_record -> 
          ext_pid = Kernel.inspect(pricing_record[:id]) # force conversion to string

          if product = Repo.get_by(Product, external_product_id: ext_pid) do
            changeset = Product.changeset(product, %{
                          product_name: pricing_record[:product_name],
                          price_in_cents: price_to_cents(pricing_record[:price])
                        })

            case changeset.changes do
              %{product_name: _product_name} ->
                Logger.warn(
                  "Omega Pricing update failed for '#{product.product_name} [#{ext_pid}]' due to a name mismatch"
                )
              %{price_in_cents: price_in_cents} ->
                original_price = "$#{product.price_in_cents / 100}"
                new_price = "$#{price_in_cents / 100}"

                product = Product.update_price!(product, price_in_cents)
                Logger.info(
                  "Omega Pricing update succeeded for '#{product.product_name} [#{ext_pid}]' from #{original_price} to #{new_price}"
                )
            end
          else
            if !pricing_record[:discontinued] do
              changeset = Product.changeset(%Product{}, %{
                            product_name: pricing_record[:product_name],
                            external_pricing_id: ext_pid,
                            price_in_cents: price_to_cents(pricing_record[:price])
                          })
              case Repo.insert(changeset) do
                {:ok, product} ->
                  Logger.info(
                    "New Product created for '#{product.product_name} [#{product.external_product_id}]'"
                  )
                {:error, _changeset} ->
                  Logger.warn(
                    "Unable to create Product for [#{ext_pid}]"
                  )
              end
            end
          end
        end
      end
    end
  end

  defp price_to_cents(price) when is_binary(price) do
    # run a regex to strip all non-digit, non-decimals
    Regex.replace ~r{[^0-9.]}, price, ""
  end
end
