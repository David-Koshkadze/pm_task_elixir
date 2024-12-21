defmodule PmTaskElixir.Repo.Migrations.CreateStatues do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :name, :string, null: false
      add :order, :integer
    end

    create unique_index(:statuses, [:name])

    alter table("tasks") do
      add :status_id, references(:statuses, on_delete: :nothing)
      remove :status
    end

    create index("tasks", [:status_id])

    execute """
    INSERT INTO statuses (name, "order")
    VALUES
      ('Todo', 1),
      ('In Progress', 2),
      ('Done', 3)
    """
  end
end
