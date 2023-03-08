defmodule Output do
  def start do
    # printer_actor = PrinterActor.start()
    # send(printer_actor, "Hello world!")
    # send(printer_actor, "hello")

    # modify_actor = ModifyActor.start()
    # send(modify_actor, 164_540)
    # send(modify_actor, "Hello")
    # send(modify_actor, [10, "Hello"])

    # monitored_pid = MonitoredActor.start()
    # MonitoringActor.start(monitored_pid)

    # average_actor = AverageActor.start()
    # send(average_actor, 0)
    # send(average_actor, 10)
    # send(average_actor, 10)
    # send(average_actor, 10)

    # main

    pid = QueueActor.new_queue()
    IO.puts(QueueActor.push(pid, 5))
    IO.puts(QueueActor.push(pid, 6))
    IO.puts(QueueActor.push(pid, 7))
    IO.puts(QueueActor.pop(pid))
    IO.puts(QueueActor.pop(pid))
    IO.puts(QueueActor.pop(pid))

    # mutex = Semaphore.start(5)
    # IO.puts(Semaphore.acquire(mutex))
    # IO.puts(Semaphore.release(mutex))

    superviser = Superviser.create_scheduler()
    Supervised.startLink(superviser)

    # Scheduler.startlink()
    
    scheduler_pid = Scheduler.start_link()
    Scheduler.send(scheduler_pid, {:new_task, "Task 1"})
    Scheduler.send(scheduler_pid, {:new_task, "Task 2"})
  end
end
