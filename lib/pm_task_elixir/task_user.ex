defmodule PmTaskElixir.TaskUser do
  use Ecto.Schema

  schema "task_users" do
    belongs_to :task, PmTaskElixir.Task
    belongs_to :user, PmTaskElixir.User

    timestamps(type: :utc_datetime)
  end
end
