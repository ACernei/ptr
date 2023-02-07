defmodule Main do
  use Application

  def start(_type, _args) do
    Hello.start()
    Supervisor.start_link([], strategy: :one_for_one)
  end
end
