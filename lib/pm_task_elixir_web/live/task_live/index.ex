defmodule PmTaskElixirWeb.Live.TaskLive.Index do
  use PmTaskElixirWeb, :live_view
  alias PmTaskElixir.Task

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :tasks, list_tasks())}
  end


  defp list_tasks() do
    Task.list_tasks()
  end
end
