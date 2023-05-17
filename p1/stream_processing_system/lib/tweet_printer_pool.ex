defmodule TweetPrinterPool do
  use Supervisor

  def start_link([worker_type, lambda, min_workers]) do
    Supervisor.start_link(__MODULE__, [worker_type, lambda, min_workers])
  end

  def init([worker_type, lambda, min_workers]) do
    worker_name = Module.split(worker_type) |> List.last()
    IO.puts("Starting #{worker_name}Pool")
    Process.register(self(), String.to_atom("#{worker_type}Pool"))

    children =
      for i <- 1..min_workers do
        worker = {worker_type, [i, lambda]}
        Supervisor.child_spec(worker, id: i, restart: :permanent)
      end

    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_num_workers(pool_type) do
    supervisor_name =
      case pool_type do
        :redactor -> TweetRedactorPool
        :sentiment -> SentimentScoreCalculatorPool
        :engagement -> EngagementRatioCalculatorPool
      end

    supervisor = Process.whereis(supervisor_name)
    children = Supervisor.which_children(supervisor)
    num_workers = length(children)
    {:ok, num_workers}
  end
end
