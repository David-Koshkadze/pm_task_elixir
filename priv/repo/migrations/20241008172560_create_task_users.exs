defmodule PmTaskElixir.Repo.Migrations.CreateTaskUsers do
  use Ecto.Migration

  def change do
    create table(:task_users) do
      add :task_id, references(:tasks, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:task_users, [:task_id])
    create index(:task_users, [:user_id])
    create unique_index(:task_users, [:task_id, :user_id])
  end
end
