defmodule PmTaskElixir.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias PmTaskElixir.TaskUser
  alias PmTaskElixir.Repo
  alias PmTaskElixir.Activity
  alias PmTaskElixir.Task

  schema "tasks" do
    field :description, :string
    field :title, :string
    field :due_date, :string
    field :sprint_points, :integer

    belongs_to :status, PmTaskElixir.Status

    many_to_many :users, PmTaskElixir.User, join_through: "task_users"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status_id, :due_date, :sprint_points])
    |> validate_required([:title, :description, :status_id, :due_date, :sprint_points])
    |> foreign_key_constraint(:status_id)
    |> cast_assoc(:users)
  end

  def change_task(%Task{}, attrs \\ %{}) do
    Task.changeset(%Task{}, attrs)
  end

  def list_tasks do
    Repo.all(from(t in Task, order_by: [desc: t.inserted_at])) |> Repo.preload(:status)
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def create_task(attrs \\ %{}) do
    Repo.transaction(fn ->
      case %Task{}
           |> Task.changeset(attrs)
           |> Repo.insert() do
        {:ok, task} ->
          log_activity(task, "created", "N/A", "N/A")
          task

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_task(%Task{} = task, attrs \\ %{}) do
    Repo.transaction(fn ->
      case task |> changeset(attrs) |> Repo.update() do
        {:ok, updated_task} ->
          log_changes(task, updated_task)
          updated_task

        {:error, changeset} ->
          IO.puts(inspect(changeset))
          Repo.rollback(changeset)
      end
    end)
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def assign_user(task, user) do
    %TaskUser{}
    |> TaskUser.changeset(%{task_id: task.id, user_id: user.id})
    |> Repo.insert()
    |> case do
      {:ok, _task_user} ->
        log_activity(task, "user_assigned", "N/A", "N/A", user.id)
        {:ok, get_task_with_users(task.id)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def remove_assignee(task, user) do
    TaskUser
    |> where(task_id: ^task.id, user_id: ^user.id)
    |> Repo.delete_all()

    {:ok, get_task_with_users(task.id)}
  end

  defp log_activity(task, action_type, old_value, new_value, user_id \\ nil) do
    %Activity{}
    |> Activity.changeset(%{
      action_type: action_type,
      task_id: task.id,
      user_id: user_id,
      old_value: old_value,
      new_value: new_value
    })
    |> Repo.insert!()
  end

  defp log_changes(old_task, new_task) do
    old_task
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__, :inserted_at, :updated_at])
    |> Enum.each(fn {key, old_value} ->
      new_value = Map.get(new_task, key)

      if old_value != new_value do
        log_activity(new_task, "updated_#{key}", "#{inspect(old_value)}", "#{inspect(new_value)}")
      end
    end)
  end

  defp get_task_with_users(task_id) do
    Task
    |> Repo.get!(task_id)
    |> Repo.preload([users: :user])
  end
end
