defmodule PmTaskElixir.Status do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias PmTaskElixir.Repo

  schema "statuses" do
    field :name, :string
    field :order, :integer
  end

  @doc false
  def changeset(status, attrs) do
    status
    |> cast(attrs, [:name, :order])
    |> validate_required([:name, :order])
    |> unique_constraint(:name)
    |> unique_constraint(:order)
  end

  def list_statuses do
    __MODULE__
    |> order_by(asc: :order)
    |> Repo.all()
  end
end
