defmodule SentimentScoreCalculator do
  use GenServer
  require HTTPoison

  def start_link([id, lambda]) do
    GenServer.start_link(__MODULE__, [id, lambda])
  end

  def init([id, lambda]) do
    IO.puts("Starting SentimentScoreCalculator#{id}")
    Process.register(self(), String.to_atom("SentimentScoreCalculator#{id}"))
    {:ok, lambda}
  end

  def handle_cast({:tweet, %EventsourceEx.Message{data: data}}, lambda) do
    case Jason.decode(data) do
      {:ok, json_data} ->
        tweet_id = json_data["message"]["tweet"]["id"]
        tweet_text = json_data["message"]["tweet"]["text"]
        emotional_scores = get_sentiment_map()
        sentiment_score = calculate_sentiment(tweet_text, emotional_scores)

        GenServer.cast(
          Process.whereis(:Aggregator),
          {:sentiment_score, sentiment_score, :id, tweet_id}
        )

        sleep_time = Statistics.Distributions.Poisson.rand(lambda) |> round()
        :timer.sleep(sleep_time)
        {:noreply, lambda}

      _ ->
        IO.puts("Error extracting tweet text from JSON data: #{data}")
        IO.puts("#{ProcessHelper.get_name(self())} DIED")
        Process.exit(self(), :kill)
        {:noreply, lambda}
    end
  end

  defp get_sentiment_map() do
    {:ok, response} = HTTPoison.get("http://localhost:4000/emotion_values")
    response_body = response.body
    lines = String.split(response_body, "\r\n")

    emotional_scores =
      lines
      |> Enum.map(&String.split(&1, "\t"))
      |> Enum.reduce(%{}, fn [word, score], acc ->
        Map.merge(acc, %{word => String.to_integer(score)})
      end)

    emotional_scores
  end

  defp calculate_sentiment(text, emotional_scores) do
    words = String.split(text, " ")
    scores = words |> Enum.map(&Map.get(emotional_scores, String.downcase(&1), 0))

    sentiment_score =
      if Enum.count(scores) > 0, do: Enum.sum(scores) / Enum.count(scores), else: 0

    sentiment_score
  end
end

defmodule EngagementRatioCalculator do
  use GenServer

  def start_link([id, lambda]) do
    GenServer.start_link(__MODULE__, [id, lambda])
  end

  def init([id, lambda]) do
    IO.puts("Starting EngagementRatioCalculator#{id}")
    Process.register(self(), String.to_atom("EngagementRatioCalculator#{id}"))
    {:ok, lambda}
  end

  def handle_cast({:tweet, %EventsourceEx.Message{data: data}}, lambda) do
    case Jason.decode(data) do
      {:ok, json_data} ->
        tweet_id = json_data["message"]["tweet"]["id"]
        favorite_count = json_data["message"]["tweet"]["favorite_count"]
        retweet_count = json_data["message"]["tweet"]["retweet_count"]
        followers_count = json_data["message"]["tweet"]["user"]["followers_count"]

        engagement_ratio =
          compute_ratio(
            favorite_count,
            retweet_count,
            followers_count
          )

        GenServer.cast(
          Process.whereis(:Aggregator),
          {:engagement_ratio, engagement_ratio, :id, tweet_id}
        )

        sleep_time = Statistics.Distributions.Poisson.rand(lambda) |> round()
        :timer.sleep(sleep_time)
        {:noreply, lambda}

      _ ->
        IO.puts("Error extracting tweet text from JSON data: #{data}")
        IO.puts("#{ProcessHelper.get_name(self())} DIED")
        Process.exit(self(), :kill)
        {:noreply, lambda}
    end
  end

  defp compute_ratio(likes, retweets, followers) do
    engagement_ratio = if followers > 0, do: (likes + retweets) / followers, else: 0
    engagement_ratio
  end
end
