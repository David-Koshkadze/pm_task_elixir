defmodule PmTaskElixir.Activity do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias PmTaskElixir.Repo
  alias PmTaskElixir.Activity

  schema "activities" do
    field :new_value, :string
    field :action_type, :string
    field :old_value, :string
    field :user_id, :id
    field :task_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:action_type, :old_value, :new_value, :task_id, :user_id])
    |> validate_required([:action_type, :task_id])
    |> validate_old_new_values()
  end

  def get_activities_by_task_id(task_id) do
    Activity
    |> where([a], a.task_id == ^task_id)
    |> Repo.all()
  end

  defp validate_old_new_values(changeset) do
    old_value = get_field(changeset, :old_value)
    new_value = get_field(changeset, :new_value)

    if is_nil(old_value) or is_nil(new_value) do
      add_error(changeset, :old_value, "old_value and new_value must be present")
    else
      changeset
    end
  end
end
