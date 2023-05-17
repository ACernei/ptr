defmodule RetweetAggregator do
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      %{
        sentiment_scores: %{},
        redacted_tweets: %{},
        engagement_ratios: %{}
      },
      name: :RetweeAggregator
    )
  end

  def init(state) do
    IO.puts("Retweet Agregator started")
    schedule_check_aggregate()
    {:ok, state}
  end

  defp schedule_check_aggregate do
    Process.send_after(self(), :check_aggregate, 100)
    :noreply
  end

  def handle_cast({:redacted_text, redacted_text, :id, message_id}, state) do
    # IO.puts("Agregator received redacted")
    redacted_tweets = Map.get(state.redacted_tweets, message_id, [])
    new_redacted_tweets = [redacted_text | redacted_tweets]

    {:noreply,
     Map.put(
       state,
       :redacted_tweets,
       Map.put(state.redacted_tweets, message_id, new_redacted_tweets)
     )}
  end

  def handle_cast({:sentiment_score, sentiment_score, :id, message_id}, state) do
    # IO.puts("Agregator received sentiment")
    sentiment_scores = Map.get(state.sentiment_scores, message_id, [])
    new_sentiment_scores = [sentiment_score | sentiment_scores]

    {:noreply,
     Map.put(
       state,
       :sentiment_scores,
       Map.put(state.sentiment_scores, message_id, new_sentiment_scores)
     )}
  end

  def handle_cast({:engagement_ratio, engagement_ratio, :id, message_id}, state) do
    # IO.puts("Agregator received engagement")
    engagement_ratios = Map.get(state.engagement_ratios, message_id, [])
    new_engagement_ratios = [engagement_ratio | engagement_ratios]

    {:noreply,
     Map.put(
       state,
       :engagement_ratios,
       Map.put(state.engagement_ratios, message_id, new_engagement_ratios)
     )}
  end

  def handle_info(:check_aggregate, state) do
    case find_matching_set(state) do
      nil ->
        IO.puts("No match found")
        schedule_check_aggregate()
        {:noreply, state}

      matching_sets ->
        Enum.each(matching_sets, fn matching_set ->
          IO.puts("\nRetweets #{inspect({:batch, matching_set})}")
          # GenServer.cast(Process.whereis(:TweetBatcher), {:batch, matching_set})
          clear_matching_set(state, matching_set)
        end)

        schedule_check_aggregate()
        {:noreply, state}
    end
  end

  defp find_matching_set(state) do
    redacted_tweets = state.redacted_tweets
    sentiment_scores = state.sentiment_scores
    engagement_ratios = state.engagement_ratios

    maps = [redacted_tweets, sentiment_scores, engagement_ratios]

    common_keys =
      Enum.reduce(maps, MapSet.new(Map.keys(redacted_tweets)), fn map, acc ->
        MapSet.intersection(acc, MapSet.new(Map.keys(map)))
      end)

    if MapSet.size(common_keys) > 0 do
      Enum.reduce(common_keys, [], fn key, matching_sets ->
        case {Map.fetch(redacted_tweets, key), Map.fetch(sentiment_scores, key),
              Map.fetch(engagement_ratios, key)} do
          {{:ok, redacted_tweet}, {:ok, sentiment_score}, {:ok, engagement_ratio}} ->
            matching_set = [key, redacted_tweet, sentiment_score, engagement_ratio]
            [matching_set | matching_sets]

          _ ->
            matching_sets
        end
      end)
    else
      nil
    end
  end

  defp clear_matching_set(state, matching_set) do
    [message_id, _, _, _] = matching_set

    %{
      state
      | redacted_tweets: Map.delete(state.redacted_tweets, message_id),
        sentiment_scores: Map.delete(state.sentiment_scores, message_id),
        engagement_ratios: Map.delete(state.engagement_ratios, message_id)
    }

    {:noreply, state}
  end
end
