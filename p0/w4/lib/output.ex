defmodule Output do
  def start do
    WorkerSupervisor.start_link(3)
    IO.inspect(WorkerSupervisor.worker_pids())
    WorkerSupervisor.send_message(1, "Hello, worker 1!")
    WorkerSupervisor.send_message(2, "Hello, worker 2!")
    WorkerSupervisor.send_message(3, "Hello, worker 3!")
    WorkerSupervisor.send_message(3, :kill)
    IO.inspect(WorkerSupervisor.worker_pids())
    WorkerSupervisor.send_message(3, "Hello again, worker 3!")

    # string_to_clean = "iNput sTrInG tO CLEAn"
    # IO.puts("String to clean: #{inspect(string_to_clean)}")
    # StringCleanerSupervisor.start_link()
    # StringCleanerSupervisor.send_input(Process.whereis(:StringSplitter), string_to_clean)
    # # StringCleanerSupervisor.send_input(Process.whereis(:StringSplitter), :kill)
    # StringCleanerSupervisor.send_input(Process.whereis(:StringJoiner), :kill)
    # StringCleanerSupervisor.send_input(Process.whereis(:StringSplitter), string_to_clean)
  end
end
