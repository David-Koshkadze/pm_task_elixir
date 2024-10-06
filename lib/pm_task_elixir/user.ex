defmodule PmTaskElixir.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string

    many_to_many :tasks, PmTaskElixir.Task, join_through: "task_users"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end

  # def create_new_user(attrs \\ %{}) do
  #   case Repo.insert attrs do
  #     {:ok, user} -> {:ok, user}
  #     {:error, changeset} -> {:error, changeset}
  #   end
  # end
end
