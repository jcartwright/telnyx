# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Telnyx.Repo.insert!(%Telnyx.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Telnyx.{Repo, Product}

Repo.insert!(%Product{
                external_product_id: "12345",
                product_name: "Nice Chair",
                price_in_cents: 40_25
              })
Repo.insert!(%Product{
                external_product_id: "23456",
                product_name: "Black & White TV",
                price_in_cents: 43_77
              })
Repo.insert!(%Product{
                external_product_id: "ACME-WIDGET-001",
                product_name: "Acme Widget 001",
                price_in_cents: 100_000_00
              })
