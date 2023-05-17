
defmodule SSEReaderSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    Process.register(self(), :SSEReaderSupervisor)

    children = [
      %{
        id: SSEReader,
        start: {SSEReader, :start_link, ["http://localhost:4000/tweets/1"]},
        restart: :permanent
      },
      %{
        id: SSEReader2,
        start: {SSEReader2, :start_link, ["http://localhost:4000/tweets/2"]},
        restart: :permanent
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule SSEReader do
  use GenServer
  require EventsourceEx
  require Logger

  :application.ensure_all_started(:hackney)

  def start_link(url \\ []) do
    GenServer.start_link(__MODULE__, url, name: :SSEReader)
  end

  def init(url) do
    EventsourceEx.new(url, stream_to: self())
    {:ok, url}
  end

  def handle_info(data, state) do
    GenServer.cast(Process.whereis(:TweetMediator), {:tweet, data})
    {:noreply, state}
  end
end

defmodule SSEReader2 do
  use GenServer
  require EventsourceEx
  require Logger

  :application.ensure_all_started(:hackney)

  def start_link(url \\ []) do
    GenServer.start_link(__MODULE__, url, name: :SSEReader2)
  end

  def init(url) do
    EventsourceEx.new(url, stream_to: self())
    {:ok, url}
  end

  def handle_info(data, state) do
    GenServer.cast(Process.whereis(:TweetMediator), {:tweet, data})
    {:noreply, state}
  end
end
