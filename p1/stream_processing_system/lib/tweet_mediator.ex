defmodule TweetMediator do
  use GenServer

  def start_link([lambda, min_workers]) do
    GenServer.start_link(__MODULE__, [lambda, min_workers], name: :TweetMediator)
  end

  def init([lambda, min_workers]) do
    IO.puts("Starting the mediator")
    {:ok, redactor_pool} = TweetPrinterPool.start_link([TweetRedactor, lambda, min_workers])

    {:ok, sentiment_calculator_pool} =
      TweetPrinterPool.start_link([SentimentScoreCalculator, lambda, min_workers])

    {:ok, engagement_ratio_pool} =
      TweetPrinterPool.start_link([EngagementRatioCalculator, lambda, min_workers])

    {:ok,
     %{
       redactor_pool: redactor_pool,
       sentiment_calculator_pool: sentiment_calculator_pool,
       engagement_ratio_pool: engagement_ratio_pool
     }}
  end

  def handle_cast({:tweet, data}, state) do
    {redactor_pid, sentiment_calculator_pid, engagement_ratio_pid} = choose_worker_pid()

    GenServer.cast(redactor_pid, {:tweet, data})
    GenServer.cast(sentiment_calculator_pid, {:tweet, data})
    GenServer.cast(engagement_ratio_pid, {:tweet, data})
    {:noreply, state}
  end

  # Least Connected
  defp choose_worker_pid() do
    {:ok, redactor_pool_size} = TweetPrinterPool.get_num_workers(:redactor)
    {:ok, sentiment_pool_size} = TweetPrinterPool.get_num_workers(:sentiment)
    {:ok, engagement_pool_size} = TweetPrinterPool.get_num_workers(:engagement)

    redactor_task_counts =
      for i <- 1..redactor_pool_size do
        redactor_worker_pid = ProcessHelper.get_worker_pid(TweetRedactor, i)

        case redactor_worker_pid do
          nil ->
            {:skip, i}

          pid ->
            info = Process.info(pid, [:message_queue_len])
            {pid, info[:message_queue_len]}
        end
      end

    sentiment_task_counts =
      for i <- 1..sentiment_pool_size do
        sentiment_worker_pid = ProcessHelper.get_worker_pid(SentimentScoreCalculator, i)

        case sentiment_worker_pid do
          nil ->
            {:skip, i}

          pid ->
            info = Process.info(pid, [:message_queue_len])
            {pid, info[:message_queue_len]}
        end
      end

    engagement_task_counts =
      for i <- 1..engagement_pool_size do
        engagement_worker_pid = ProcessHelper.get_worker_pid(EngagementRatioCalculator, i)

        case engagement_worker_pid do
          nil ->
            {:skip, i}

          pid ->
            info = Process.info(pid, [:message_queue_len])
            {pid, info[:message_queue_len]}
        end
      end

    sorted_redactor_workers = Enum.sort_by(redactor_task_counts, fn {_pid, count} -> count end)
    {redactor_pid, _} = hd(sorted_redactor_workers)

    sorted_sentiment_workers = Enum.sort_by(sentiment_task_counts, fn {_pid, count} -> count end)
    {sentiment_calculator_pid, _} = hd(sorted_sentiment_workers)

    sorted_engagement_workers =
      Enum.sort_by(engagement_task_counts, fn {_pid, count} -> count end)

    {engagement_ratio_pid, _} = hd(sorted_engagement_workers)

    {redactor_pid, sentiment_calculator_pid, engagement_ratio_pid}
  end
end
