defmodule PmTaskElixirWeb.Live.TaskLive.Index do
  use PmTaskElixirWeb, :live_view
  alias PmTaskElixir.Task

  def mount(_params, _session, socket) do
    {:ok, assign(socket, tasks: list_tasks(), selected_task: nil)}
  end

  def handle_event("create", %{"task" => task_params}, socket) do
    case Task.create_task(task_params) do
      {:ok, _task} ->
        {:noreply, assign(socket, :tasks, list_tasks())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # delete task
  def handle_event("delete", %{"id" => id}, socket) do
    task = Task.get_task!(id)

    case Task.delete_task(task) do
      {:ok, _} ->
        socket = assign(socket, :tasks, list_tasks())

        {:noreply,
         socket
         |> put_flash(:info, "Task deleted successfully")
         |> push_navigate(to: ~p"/tasks")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete task")}
    end
  end

  def handle_event("show_modal", %{"id" => id}, socket) do
    task = Task.get_task!(id)
    {:noreply, assign(socket, selected_task: task)}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, selected_task: nil)}
  end

  defp list_tasks() do
    Task.list_tasks()
  end
end
