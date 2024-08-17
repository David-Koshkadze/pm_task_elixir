defmodule PmTaskElixir.Task do
  use Ecto.Schema
  import Ecto.Changeset

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
end
