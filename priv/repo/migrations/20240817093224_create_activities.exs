defmodule PmTaskElixir.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :action_type, :string
      add :old_value, :string
      add :new_value, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :task_id, references(:tasks, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:activities, [:user_id])
    create index(:activities, [:task_id])
  end
end
