# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PmTaskElixir.Repo.insert!(%PmTaskElixir.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

PmTaskElixir.Repo.insert!(%PmTaskElixir.Status{
  name: "Todo",
  order: 1
})
