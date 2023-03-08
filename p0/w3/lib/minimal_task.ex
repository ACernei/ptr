defmodule PrinterActor do
  def start do
    spawn(fn -> loop() end)
  end

  def loop do
    receive do
      msg -> IO.inspect(msg)
    end

    loop()
  end
end

defmodule ModifyActor do
  def start do
    spawn(fn -> loop() end)
  end

  def loop do
    receive do
      msg ->
        if is_integer(msg) do
          IO.puts("Received: #{msg + 1}")
        else
          if is_binary(msg) do
            IO.puts("Received: #{msg |> String.trim() |> String.upcase()}")
          else
            IO.puts("Received: I don’t know how to handle this!")
          end
        end
    end

    loop()
  end
end

defmodule MonitoredActor do
  def start do
    spawn(fn ->
      IO.puts("Monitored Actor says: Finished!")
      Process.exit(self(), :kill)
    end)
  end
end

defmodule MonitoringActor do
  def start(monitored_actor) do
    spawn(fn -> monitor_loop(monitored_actor) end)
  end

  def monitor_loop(monitored_actor) do
    Process.monitor(monitored_actor)

    receive do
      {:DOWN, _, _, _, reason} ->
        IO.puts("Monitoring Actor recieved message: stopped with reason '#{reason}'")
    end
  end
end

defmodule AverageActor do
  def start() do
    spawn(fn -> loop() end)
  end

  def loop() do
    receive do
      number ->
        initial_average = number
        IO.puts("Current average is #{initial_average}")
        loop(initial_average)
    end
  end

  def loop(average) do
    receive do
      number ->
        new_average = (average + number) / 2
        IO.puts("Current average is #{new_average}")
        loop(new_average)
    end
  end
end
