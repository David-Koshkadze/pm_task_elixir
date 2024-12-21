defmodule PmTaskElixir.Repo.Migrations.AddRelationOfUsersToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :user_id, references(:users, on_delete: :nothing)
    end

    create index(:activities, [:user_id])
  end
end
