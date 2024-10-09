defmodule PmTaskElixir.Repo.Migrations.RemoveUsers do
  use Ecto.Migration

  def change do
    execute "DROP EXTENSION IF EXISTS users CASCADE"
  end
end
