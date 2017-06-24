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
              id: 12345,
              name: "Nice Chair",
              price: "$30.25",
              category: "home-furnishings",
              discontinued: false
            },
            %{
              id: 234567,
              name: "Black & White TV",
              price: "$43.77",
              category: "electronics",
              discontinued: true
            }
        ]}
      }
    }
  end

end
