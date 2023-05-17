defmodule TweetRedactor do
  use GenServer

  @bad_words File.read!("lib/bad-words.txt") |> String.split("\r\n")

  def start_link([id, lambda]) do
    GenServer.start_link(__MODULE__, [id, lambda])
  end

  def init([id, lambda]) do
    IO.puts("Starting TweetRedactor#{id}")
    Process.register(self(), String.to_atom("TweetRedactor#{id}"))
    {:ok, lambda}
  end

  def handle_cast({:tweet, %EventsourceEx.Message{data: data}}, lambda) do
    case Jason.decode(data) do
      {:ok, json_data} ->
        tweet_id = json_data["message"]["tweet"]["id"]
        tweet_text = json_data["message"]["tweet"]["text"]
        user_id = json_data["message"]["tweet"]["user"]["id"]
        user_name = json_data["message"]["tweet"]["user"]["name"]
        redacted_text = redact(tweet_text)

        GenServer.cast(
          Process.whereis(:Aggregator),
          {:redacted_text,
           %{:text => redacted_text, :user_id => user_id, :user_name => user_name}, :id, tweet_id}
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

  defp redact(text) do
    String.split(text, " ")
    |> Enum.map(fn word ->
      original_word = word

      if Enum.member?(@bad_words, String.downcase(word)) do
        String.duplicate("*", String.length(word))
      else
        original_word
      end
    end)
    |> Enum.join(" ")
  end
end
