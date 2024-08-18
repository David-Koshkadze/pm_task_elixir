defmodule PmTaskElixirWeb.Live.TaskLive.Index do
  use PmTaskElixirWeb, :live_view
  alias PmTaskElixir.Task

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tasks, list_tasks())}
  end

  def handle_event("create", %{"task" => task_params}, socket) do
    case Task.create_task(task_params) do
      {:ok, _task} ->
        {:noreply, assign(socket, :tasks, list_tasks())}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp list_tasks() do
    Task.list_tasks()
  end
end
