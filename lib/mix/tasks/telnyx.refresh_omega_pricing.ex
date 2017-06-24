defmodule Mix.Tasks.Telnyx.RefreshOmegaPricing do
  use Mix.Task
  require Logger

  import Mix.Ecto
  use Timex

  @shortdoc "Refresh the `products` table with Omega Pricing information"
  def run(args) do
    repos = parse_repo(args)

    # We have to manually ensure the Ecto.Repo is started since we're
    # unsupervised in Mix.Task land...
    Enum.each repos, fn repo ->
      ensure_repo(repo, args)
      ensure_started(repo, [])
    
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(repo)
      Ecto.Adapters.SQL.Sandbox.mode(repo, {:shared, self()})

      start_date = Timex.shift(Timex.today, months: -1)
      end_date = Timex.today

      Logger.info "Refreshing Omega Pricing information from #{start_date} to #{end_date}"

      case Telnyx.PriceUpdater.update_prices(:omega_pricing, start_date, end_date) do
        {:ok, results} ->
          # Display Results
          render_results_table(results)
        {:error, _} ->
          Logger.error "An unexpected error occurred"
      end

      Logger.info "Omega Pricing Refresh process completed"
    end
  end

  defp render_results_table(results) do
    #TODO: Pretty-print results in a table
    IO.inspect results
  end
end
