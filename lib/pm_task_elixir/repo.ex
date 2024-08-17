defmodule PmTaskElixir.Repo do
  use Ecto.Repo,
    otp_app: :pm_task_elixir,
    adapter: Ecto.Adapters.Postgres
end
