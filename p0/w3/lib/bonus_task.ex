defmodule Supervised do
  def startLink(superviser) do
    pid = spawn_link(__MODULE__, :doAction, [superviser])
    Process.register(pid, :supervised)
    pid
  end

  def doAction(supervisor) do
    if :rand.uniform(2) == 1 do
      exit(:normal)
    else
      IO.puts("This is worker. I am done.")
      send(supervisor, {:completed})
    end
  end
end

defmodule Superviser do
  def create_scheduler() do
    spawn(__MODULE__, :receive_task, [])
  end

  def receive_task() do
    receive do
      {:new_task} -> supervise()
    end

    receive_task()
  end

  def supervise() do
    supervisor = self()

    pid =
      spawn(fn ->
        if :rand.uniform(2) == 1 do
          Process.exit(self(), :fail)
        else
          IO.puts("This is worker. I am done.")
          send(supervisor, {:completed})
        end
      end)

    _ref = Process.monitor(pid)

    receive do
      {:completed} ->
        IO.puts("The worker solved its task!")

      {:DOWN, _ref, :process, _object, :fail} ->
        IO.puts("Worker failed. Restarting it...")
    end

    supervise()
  end
end

superviser = Superviser.create_scheduler()
Supervised.startLink(superviser)
