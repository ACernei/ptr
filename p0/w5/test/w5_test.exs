defmodule W5Test do
  use ExUnit.Case
  doctest W5

  test "greets the world" do
    assert W5.hello() == :world
  end
end
