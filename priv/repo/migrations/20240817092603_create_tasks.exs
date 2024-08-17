defmodule PmTaskElixir.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :text
      add :status, :string
      add :due_date, :string
      add :sprint_points, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
