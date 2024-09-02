defmodule PmTaskElixirWeb.Live.TaskLive.New do
  use PmTaskElixirWeb, :live_view

  alias PmTaskElixir.{Task, Status}

  def mount(_params, _session, socket) do
    changeset = Task.change_task(%Task{})
    statuses = Status.list_statuses()

    {:ok, assign(socket, form: to_form(changeset), statuses: statuses)}
  end

  def update(%{task: task} = assigns, socket) do
    changeset = Task.change_task(task)
    statuses = Status.list_statuses()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:statuses, statuses)}
  end

  def handle_event("validate", %{"task" => task_params}, socket) do
    form =
      %Task{}
      |> Task.change_task(task_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  # save task when creating new task or editing
  def handle_event("save", %{"task" => task_params}, socket) do
    # save_task(socket, socket.assigns.action, task_params)
    save_task(socket, :new, task_params)
  end

  # according to socket.assigns.action below two functions will be called to save task
  defp save_task(socket, :new, task_params) do
    case Task.create_task(task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> redirect(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts(changeset)
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_task(socket, :edit, task_params) do
    case Task.update_task(socket.assigns.task, task_params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> redirect(to: ~p"/tasks")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
