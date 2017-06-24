defmodule Telnyx.OmegaPricingService do
  use HTTPoison.Base
  use Timex

  @config   Application.get_env(:telnyx, Telnyx.OmegaPricingService)
  @endpoint @config[:endpoint]
  @api_key  @config[:api_key]

  ### Public API

  def fetch_pricing_records(), 
    do: fetch_pricing_records(Timex.shift(Timex.today, months: -1), Timex.today)

  def fetch_pricing_records(start_date, end_date) do
    records =
      fetch_pricing_data(start_date, end_date)
      |> convert_to_pricing_records()
    {:ok, records}
  end

  def pricing_service_url(start_date, end_date) do
    "pricing/records.json?" <>
      URI.encode_query(%{
        api_key:    @api_key,
        start_date: start_date,
        end_date:   end_date
      })
    |> process_url()
  end

  ### Private Methods

  defp fetch_pricing_data(start_date, end_date) do
    case make_request(:get, pricing_service_url(start_date, end_date)) do
      {:ok, response} ->
        response[:body]
    end
  end

  defp convert_to_pricing_records(%{pricingRecords: pricing_records}) do
    Enum.map pricing_records, fn raw ->
      %Telnyx.OmegaPricingRecord{
        id:           raw[:id],
        name:         raw[:name],
        price:        raw[:price],
        category:     raw[:category],
        discontinued: raw[:discontinued]
      }
    end
  end

  ## HTTPoison overrides

  defp process_url(url) do
    @endpoint <> url
  end

  defp headers do
    %{
      "Content-type": "application/json",
      "Accept": "application/json"
    }
  end

  defp make_request(:get, url) do
    # TODO: When we have a functional API endpoint, call it
    # get(url, headers())

    # Mock response
    {:ok, %{
      body:
        %{pricingRecords: [
            %{
              # :noop represents a product that will not
              # be updated as part of the refresh.
              id: "noop",
              name: "No-Op Product",
              price: "$1.00",
              category: "home-furnishings",
              discontinued: false
            },
            %{
              # :mismatch represents a product that will
              # match on external_product_id, but will
              # have a product name mismatch.
              id: "mismatch",
              name: "[Discontinued] Mismatch Product",
              price: "$0.00",
              category: "electronics",
              discontinued: true
            },
            %{
              # :update represents a product that will
              # generate a valid price change. The
              # external_product_id and name will match,
              # and the price will be different.
              id: "update",
              name: "Update Product",
              price: "$2.00",
              category: "misc",
              discontinued: false
            },
            %{
              # :insert represents a product that does
              # not exist in our product database and 
              # will be created on refresh.
              id: "insert",
              name: "New Product",
              price: "$12.50",
              category: "electronics",
              discontinued: false
            }
        ]}
      }
    }
  end

end
