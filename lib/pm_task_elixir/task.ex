defmodule PmTaskElixir.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias PmTaskElixir.Repo
  alias PmTaskElixir.Activity
  alias PmTaskElixir.Task

  schema "tasks" do
    field :status, :string
    field :description, :string
    field :title, :string
    field :due_date, :string
    field :sprint_points, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :due_date, :sprint_points])
    |> validate_required([:title, :description, :status, :due_date, :sprint_points])
  end

  def list_tasks do
    Repo.all(Task)
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

  def update_task(%Task{} = task, attrs) do
    Repo.transaction(fn ->
      case task |> changeset(attrs) |> Repo.update() do
        {:ok, updated_task} ->
          log_changes(task, updated_task)
          updated_task
        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  defp log_activity(task, action_type, old_value, new_value) do
    %Activity{}
    |> Activity.changeset(%{
      task_id: task.id,
      action_type: action_type,
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
end
