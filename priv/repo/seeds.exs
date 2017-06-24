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
                external_product_id: "test-product",
                product_name: "Test Product",
                price_in_cents: 1_00
              })
Repo.insert!(%Product{
                external_product_id: "noop",
                product_name: "No-Op Product",
                price_in_cents: 1_00
              })
Repo.insert!(%Product{
                external_product_id: "mismatch",
                product_name: "Mismatch Product",
                price_in_cents: 1_00
              })
Repo.insert!(%Product{
                external_product_id: "update",
                product_name: "Update Product",
                price_in_cents: 1_00
              })
