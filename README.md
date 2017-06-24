# Telnyx Code Challenge - Elixir

I chose to complete the Telnyx code challenge using Elixir and Phoenix.

## Coding Assumptions

1. No actual API to call

> The challenge describes making a call to the Omega Pricing API, but it obviously doesn't exist. Normally, I would either write my tests against a sandbox version of the API, using something like `VCR` to record and replay the responses. I would also consider setting up a Mock API, but I felt like that was out of the scope of this challenge. 

2. Mock response for creating predictable, repeatable results

> To get things working, I built out a basic `OmegaPricingService` module that imports `HTTPoison.Base`, but returns a static mock payload instead of making any actual HTTP calls. In this payload I account for each of the business requirement scenarios, and use the `id` and `external_product_id` to map products to their intended results. 

3. Use a custom `mix` task to run the Price Refresh process periodically

> Based on the business requirement to run the Price Refresh process periodically, I decided to create a custom task `$ mix telnyx.refresh_omega_pricing` so that it could be easily setup with cron or some other scheduler.

> Getting the mix task and ecto all playing nicely in `:dev` mode was more challenging than I had planned. When I first created the mix task, I just put all the logic directly in the `run/1` function and it worked with `Mix.Ecto`. But when I refactored the update function into a service class, I ran into errors like `** (DBConnection.OwnershipError) cannot find ownership process for #PID<0.70.0>.`. By setting up the `:dev` ecto config more similar to `:test`, I was able to get things working, but I feel like there's a better way.

## Libraries

I chose a few libraries to aid and ease implementation.

1. [HTTPoison](https://github.com/edgurgel/httpoison) - Adds an easily extensible approach to wrap HTTP calls in a module to encapsulate the API Client.
1. [Timex](https://github.com/bitwalker/timex) - Makes working with Dates & Times much nicer in Elixir, including `Timex.shift` to calculate 1 month ago.
1. [Number](https://github.com/danielberkompas/number) - Easy formatting of numbers in Elixir. This wasn't heavily used, so I only imported `Number.Currency.number_to_currency/1` where I needed it.

## How to Review

The best way to review the running code is to use the mix task `mix telnyx.refresh_omega_pricing` and review the output. Assuming you have cloned the project to `<projects>/telnyx`, here are the steps to take:

```
$ cd <projects>/telnyx
$ mix deps.get
$ mix ecto.setup
```

Then to run the process:

```
$ mix telnyx.refresh_omega_pricing
```

And to re-run it again:

```
$ mix ecto.reset
$ mix telnyx.refresh_omega_pricing
```
## How it meets the challenge

When the task is run, the `Telnyx.PriceUpdater.update_prices` function calls the `Telnyx.OmegaPricingService.fetch_pricing_records` function, which simulates a call to the endpoint `https://omegapricinginccom/pricing/records.json?api_key=####&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD` and returns a JSON payload. The `pricingRecords` are converted into `OmegaPriceRecord` structs, and returned as a List to the calling function.

The process continues by mapping over the pricing records, and applying the business logic specified in the challenge. For each record processed, a log statement is output with the appropriate severity and message. In addition to the log output, a tuple is added to the results, which is the final output of `Telnyx.PriceUpdater.update_prices/3`.

**Sample Output:**

```
telnyx master % mix telnyx.refresh_omega_pricing

15:31:20.977 [info]  Refreshing Omega Pricing information from 2017-05-24 to 2017-06-24

15:31:21.011 [info]  Omega Pricing no change for 'No-Op Product [noop]'

15:31:21.012 [warn]  Omega Pricing update failed for 'Mismatch Product [mismatch]' due to a name mismatch

15:31:21.044 [info]  Omega Pricing update succeeded for 'Update Product [update]' from $100.00 to $200.00

15:31:21.045 [info]  New Product created for 'New Product [insert]'

[noop: "Omega Pricing no change for 'No-Op Product [noop]'",
 mismatch: "Omega Pricing update failed for 'Mismatch Product [mismatch]' due to a name mismatch",
 ok: "Omega Pricing update succeeded for 'Update Product [update]' from $100.00 to $200.00",
 ok: "New Product created for 'New Product [insert]'"]

15:31:21.047 [info]  Omega Pricing Refresh process completed
```
