defmodule W4Test do
  use ExUnit.Case
  doctest W4

  test "greets the world" do
    assert W4.hello() == :world
  end
end
