defmodule QueueActor do
  def new_queue do
    spawn_link(__MODULE__, :init, [[]])
  end

  def push(pid, item) do
    send(pid, {:push, item})
    :ok
  end

  def pop(pid) do
    send(pid, {:pop, self()})

    receive do
      {:value, item} ->
        item
    end
  end

  def init(queue) do
    receive do
      {:push, item} ->
        if queue do
          new_queue = queue ++ [item]
          init(new_queue)
        end

      {:pop, pid} ->
        if queue == [] do
          init([])
        else
          [item | rest] = queue
          send(pid, {:value, item})
          init(rest)
        end
    end
  end
end

defmodule Semaphore do
  def start(count) do
    spawn_link(fn -> init(count) end)
  end

  defp init(count) do
    receive do
      {:acquire, sender} ->
        # IO.puts("Received from Acquire")
        # IO.inspect(sender)
        if count > 0 do
          send(sender, :ok)
          init(count - 1)
        else
          init(count)
        end

      {:release, sender} ->
        # IO.puts("Received from Release")
        # IO.inspect(sender)
        send(sender, :ok)
        init(count + 1)

      :shutdown ->
        :ok
    end
  end

  def acquire(semaphore) do
    send(semaphore, {:acquire, self()})

    receive do
      :ok ->
        :ok
        IO.puts("Aquired")
    end
  end

  def release(semaphore) do
    send(semaphore, {:release, self()})

    receive do
      :ok ->
        :ok
        IO.puts("Released")
    end
  end

  def shutdown(semaphore) do
    send(semaphore, :shutdown)
  end
end
