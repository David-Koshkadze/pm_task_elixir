defmodule PmTaskElixirWeb.Live.TaskLive.New do
  use PmTaskElixirWeb, :live_view

  alias PmTaskElixir.Task

  def mount(_params, _session, socket) do
    changeset = Task.change_task(%Task{})
    {:ok, assign(socket, :changeset, changeset)}
  end

  def update(%{task: task} = assigns, socket) do
    changeset = Task.change_task(task)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      socket.assigns.task
      |> Task.change_task(task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # save task when creating new task or editing
  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.action, task_params)
  end

  # according to socket.assigns.action below two functions will be called to save task
  defp save_task(socket, :new, task_params) do
    case Task.create_task(task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_task(socket, :edit, task_params) do
    case Task.update_task(socket.assigns.task, task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_navigate(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
