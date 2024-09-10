defmodule PmTaskElixir.TaskUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_users" do
    belongs_to :task, PmTaskElixir.Task
    belongs_to :user, PmTaskElixir.User

    timestamps(type: :utc_datetime)
  end

  def changeset(task_user, attrs) do
    task_user
    |> cast(attrs, [:task_id, :user_id])
    |> validate_required([:task_id, :user_id])
    |> unique_constraint([:task_id, :user_id], message: "User is already assigned to this task")
  end
end
