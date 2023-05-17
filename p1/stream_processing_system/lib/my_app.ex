defmodule MyApp do
  def start_link do
    lambda = 50
    min_workers = 3
    batch_size = 10
    time_window = 50
    {:ok, reader_supervisor_pid} = SSEReaderSupervisor.start_link()
    TweetMediator.start_link([lambda, min_workers])
    RetweetAggregator.start_link()
    Aggregator.start_link()
    TweetBatcher.start_link(batch_size, time_window)

    :timer.sleep(5000)
    Process.exit(reader_supervisor_pid, :normal)
  end
end
