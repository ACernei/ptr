defmodule Prime do
  def is_prime?(n) when n <= 1 do
    false
  end

  def is_prime?(2) do
    true
  end

  def is_prime?(n) do
    Enum.all?(2..round(:math.sqrt(n)), fn x -> rem(n, x) != 0 end)
  end
end

defmodule Cylinder do
  def area(height, radius) do
    2 * :math.pi() * radius * (radius + height)
  end
end

defmodule ListUtils do
  def reverse(list) do
    Enum.reverse(list)
  end

  def sum_of_unique_elements(list) do
    Enum.uniq(list) |> Enum.sum()
  end

  def extract_random_elements(list, count) do
    Enum.take_random(list, count)
  end

  def rotate_left(list, n) do
    {left, right} = Enum.split(list, n)
    right ++ left
  end

  def remove_consecutive_duplicates(list) do
    Enum.dedup(list)
  end
end

defmodule Fibonacci do
  def fib(0), do: 1
  def fib(1), do: 1
  def fib(n), do: fib(n - 2) + fib(n - 1)

  def n_fibonacci(n) do
    Enum.map(0..(n - 1), &Fibonacci.fib/1)
  end
end

defmodule Translator do
  def translate(dict, sentence) do
    sentence
    |> String.split()
    |> Enum.map(fn word -> String.to_atom(word) end)
    |> Enum.map(fn word -> Map.get(dict, word, word) end)
    |> Enum.map(fn word -> to_string(word) end)
    |> Enum.join(" ")
  end
end

defmodule NumberUtils do
  def smallest_number(a, b, c) do
    digits = [a, b, c]

    digits
    |> Enum.sort()
    |> swap_zero_with_second_digit()
    |> Enum.join()
    |> to_string()
  end

  defp swap_zero_with_second_digit(list) do
    case list do
      [0 | rest] ->
        [Enum.at(rest, 0), 0 | Enum.drop(rest, 1)]

      _ ->
        list
    end
  end
end

defmodule PythagoreanTriplets do
  def find() do
    Enum.flat_map(1..20, &find_triplets_for_a(&1))
  end

  defp find_triplets_for_a(a) do
    Enum.map(1..20, fn b -> {a, b, :math.sqrt(:math.pow(a, 2) + :math.pow(b, 2))} end)
    |> Enum.filter(fn {_, _, c} -> c == Float.floor(c) end)
  end
end

defmodule KeyboardRow do
  @first_row ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
  @second_row ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
  @third_row ["z", "x", "c", "v", "b", "n", "m"]

  def line_words(words) do
    words
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&String.graphemes/1)
    |> Enum.filter(fn word -> one_row_word?(word) end)
    |> Enum.map(&Enum.join/1)
  end

  defp one_row_word?(word) do
    keyboard_rows = [@first_row, @second_row, @third_row]
    Enum.any?(keyboard_rows, fn keyboard_row -> all_in_row?(word, keyboard_row) end)
  end

  defp all_in_row?(word, keyboard_row) do
    Enum.all?(word, fn char -> Enum.member?(keyboard_row, char) end)
  end
end
