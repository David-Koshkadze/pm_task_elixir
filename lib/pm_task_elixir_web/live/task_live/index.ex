defmodule PmTaskElixirWeb.Live.TaskLive.Index do
  alias PmTaskElixir.Activity
  use PmTaskElixirWeb, :live_view
  alias PmTaskElixir.Task
  alias PmTaskElixir.Repo
  alias PmTaskElixir.Status
  alias PmTaskElixir.User

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       tasks: Task.list_tasks(),
       selected_task: nil,
       users: Repo.all(User),
       statuses: Repo.all(Status),
       editing_title: false
     )}
  end

  # --- handle_event ---
  def handle_event("create", %{"task" => task_params}, socket) do
    case Task.create_task(task_params) do
      {:ok, _task} ->
        {:noreply, assign(socket, :tasks, Task.list_tasks())}

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

  # updating task when any changes are made
  def handle_event("update_task", params, socket) do
    %{selected_task: selected_task} = socket.assigns

    attrs = %{
      status_id: params["status_id"] || selected_task.status_id,
      description: params["description"] || selected_task.description,
      sprint_points: params["sprint_points"] || selected_task.sprint_points
    }

    case Task.update_task(selected_task, attrs) do
      {:ok, updated_task} ->
        activities = Activity.get_activities_by_task_id(selected_task.id)

        {:noreply, assign(socket, selected_task: updated_task, activities: activities)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update task")}
    end
  end

  def handle_event("show_modal", %{"id" => id}, socket) do
    task = get_task_preload(id)
    IO.inspect(task.status, label: "Loaded Status")

    # fetching activites
    activities = Activity.get_activities_by_task_id(id)

    users = Repo.all(User)
    Process.send_after(self(), :show_modal, 50)

    {:noreply,
     assign(socket,
       selected_task: task,
       show_modal: false,
       editing_title: false,
       users: users,
       activities: activities
     )}
  end

  def handle_event("hide_modal", _, socket) do
    {:noreply, assign(socket, selected_task: nil, tasks: list_tasks())}
  end

  # --- editing title ---
  def handle_event("edit_title", _, socket) do
    {:noreply, assign(socket, editing_title: true)}
  end

  def handle_event("cancel_edit_title", _, socket) do
    {:noreply, assign(socket, editing_title: false)}
  end

  def handle_event("save_title", %{"title" => title}, socket) do
    %{selected_task: selected_task} = socket.assigns

    case Task.update_task(selected_task, %{title: title}) do
      {:ok, updated_task} ->
        {:noreply, assign(socket, selected_task: updated_task, editing_title: false)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update title")}
    end
  end

  # --- assign users to the task ---
  def handle_event("assign_user", %{"user_id" => user_id}, socket) do
    IO.inspect(user_id, label: "User ID: ")

    %{selected_task: selected_task} = socket.assigns

    case Integer.parse(user_id) do
      {parsed_user_id, _} ->
        user = Repo.get(User, parsed_user_id)

        case Task.assign_user(selected_task, user) do
          {:ok, _} ->
            updated_task = get_task_preload(selected_task.id)
            activities = Activity.get_activities_by_task_id(selected_task.id)

            {:noreply, assign(socket, selected_task: updated_task, activities: activities)}

          {:error, changeset} ->
            {:noreply, put_flash(socket, :error, error_to_string(changeset))}
        end

      :error ->
        {:noreply, put_flash(socket, :error, "Failed to assign user")}
    end
  end

  def handle_event("remove_assignee", %{"user_id" => user_id}, socket) do
    %{selected_task: selected_task} = socket.assigns

    case Integer.parse(user_id) do
      {parsed_user_id, _} ->
        user = Repo.get!(User, parsed_user_id)

        case Task.remove_assignee(selected_task, user) do
          {:ok, updated_task} ->
            {:noreply, assign(socket, selected_task: updated_task)}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Failed to remove assignee: #{reason}")}
        end

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Invalid used ID")}
    end
  end

  # cathch unhandled events
  def handle_event(event, _params, socket) do
    IO.puts("Unhandled event: #{event}")
    # IO.inspect(socket)
    {:noreply, socket}
  end

  # --- handle_info ---
  def handle_info(:show_modal, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  defp list_tasks do
    Task.list_tasks()
  end

  defp get_task_preload(id) do
    Task.get_task!(id) |> Repo.preload([:status, :users])
  end

  defp error_to_string(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{k}: #{joined_errors}\n"
    end)
  end
end
