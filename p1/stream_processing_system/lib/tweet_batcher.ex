defmodule TweetBatcher do
  use GenServer

  def start_link(batch_size, time_window) do
    GenServer.start_link(__MODULE__, {batch_size, time_window}, name: :TweetBatcher)
  end

  def init({batch_size, time_window}) do
    IO.puts("Starting the Batcher")
    time_ref = print_after(time_window)

    state = %{
      matching_sets: [],
      batch_size: batch_size,
      time_window: time_window,
      time_ref: time_ref
    }

    {:ok, state}
  end

  defp print_after(time_window) do
    Process.send_after(:TweetBatcher, :timeout, time_window)
  end

  def handle_cast({:batch, matching_set}, state) do
    new_matching_sets =
      if Enum.member?(state.matching_sets, matching_set) do
        state.matching_sets
      else
        [matching_set | state.matching_sets]
      end

    if length(new_matching_sets) == state.batch_size do
      Process.cancel_timer(state.time_ref)
      IO.puts("\nBatch of #{state.batch_size} tweets:")

      new_matching_sets
      |> Enum.map(fn matching_set ->
        user_id = matching_set |> Enum.at(1) |> Map.get(:user_id)
        user_name = matching_set |> Enum.at(1) |> Map.get(:user_name)
        tweet = matching_set |> Enum.at(1) |> Map.get(:text)
        tweet_id = matching_set |> Enum.at(0)
        sentiment = matching_set |> Enum.at(2)
        engagement = matching_set |> Enum.at(3)

        user_changeset = User.changeset(%User{}, %{id: user_id, user_name: user_name})

        tweet_changeset =
          Tweet.changeset(%Tweet{}, %{
            id: tweet_id,
            message: tweet,
            sentiment: sentiment,
            engagement: engagement,
            user_id: user_id
          })

        Tweets.Repo.insert(user_changeset, on_conflict: :nothing)
        Tweets.Repo.insert(tweet_changeset, on_conflict: :nothing)
      end)

      new_time_ref = print_after(state.time_window)
      {:noreply, %{state | matching_sets: [], time_ref: new_time_ref}}
    else
      {:noreply, %{state | matching_sets: new_matching_sets}}
    end
  end

  def handle_info(:timeout, state) do
    if length(state.matching_sets) > 0 do
      IO.puts("\nThe time has come")
      IO.puts("Batch of #{length(state.matching_sets)} tweets (due to time out):")

      state.matching_sets
      |> Enum.map(fn matching_set ->
        user_id = matching_set |> Enum.at(1) |> Map.get(:user_id)
        user_name = matching_set |> Enum.at(1) |> Map.get(:user_name)
        tweet = matching_set |> Enum.at(1) |> Map.get(:text)
        tweet_id = matching_set |> Enum.at(0)
        sentiment = matching_set |> Enum.at(2)
        engagement = matching_set |> Enum.at(3)

        user_changeset = User.changeset(%User{}, %{id: user_id, user_name: user_name})

        tweet_changeset =
          Tweet.changeset(%Tweet{}, %{
            id: tweet_id,
            message: tweet,
            sentiment: sentiment,
            engagement: engagement,
            user_id: user_id
          })

        Tweets.Repo.insert(user_changeset, on_conflict: :nothing)
        Tweets.Repo.insert(tweet_changeset, on_conflict: :nothing)
      end)

      new_time_ref = print_after(state.time_window)
      {:noreply, %{state | matching_sets: [], time_ref: new_time_ref}}
    else
      new_time_ref = print_after(state.time_window)
      {:noreply, %{state | time_ref: new_time_ref}}
    end
  end
end
