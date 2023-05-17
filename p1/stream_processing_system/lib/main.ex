defmodule Main do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Tweets.Repo,
      %{
        id: MyApp,
        start: {MyApp, :start_link, []},
        restart: :permanent
      }
    ]

    opts = [strategy: :one_for_one, name: Lab2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
