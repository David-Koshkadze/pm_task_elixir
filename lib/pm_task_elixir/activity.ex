defmodule PmTaskElixir.Activity do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [:action_type, :old_value, :new_value])
    |> validate_required([:action_type, :old_value, :new_value])
  end
end
