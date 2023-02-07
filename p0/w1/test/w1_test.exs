defmodule W1Test do
  use ExUnit.Case

  test "hello ptr" do
    assert W1.hello() == "Hello PTR"
  end
end
