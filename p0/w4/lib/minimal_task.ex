defmodule Worker do
  use GenServer

  def start_link(worker_id) do
    GenServer.start_link(__MODULE__, worker_id)
  end

  def init(worker_id) do
    Process.register(self(), String.to_atom("Worker#{worker_id}"))
    IO.puts("Entered init worker #{inspect(worker_id)} with #{inspect(self())}")
    {:ok, worker_id}
  end

  def handle_cast(:kill, state) do
    IO.puts("Worker #{inspect(self())} received :kill message, stopping")
    Process.exit(self(), :kill)
    {:stop, :kill, state}
  end

  def handle_cast(message, _state) do
    IO.puts("Worker #{inspect(self())} received message: #{inspect(message)}")
    {:noreply, nil}
  end
end

defmodule WorkerSupervisor do
  use Supervisor

  def start_link(worker_count) do
    Supervisor.start_link(__MODULE__, worker_count)
  end

  def init(worker_count) do
    IO.puts("Supervisor entered init")
    Process.register(self(), :WorkerSupervisor)

    children =
      for i <- 1..worker_count do
        worker = {Worker, i}
        Supervisor.child_spec(worker, id: i, restart: :permanent)
      end

    IO.puts("Supervisor starts workers")
    Supervisor.init(children, strategy: :one_for_one)
  end

  def send_message(worker_id, message) do
    worker_pid = Process.whereis(String.to_atom("Worker#{worker_id}"))

    case worker_pid do
      nil ->
        IO.puts("Worker #{worker_id} not found")

      pid ->
        case message do
          :kill ->
            IO.puts("Send :kill message to Worker#{worker_id}")
            GenServer.cast(pid, :kill)
            :timer.sleep(1)

          text ->
            IO.puts("Send message to Worker#{worker_id}")
            GenServer.cast(pid, text)
        end
    end
  end

  def worker_pids do
    supervisor_pid = Process.whereis(:WorkerSupervisor)
    IO.puts("Getting children pids")
    children = Supervisor.which_children(supervisor_pid)
    _child_pids = Enum.map(children, fn {_, pid, _, _} -> pid end)
  end
end
