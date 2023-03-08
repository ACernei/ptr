# --- see ListUtils from minimal_task---
# defmodule ListUtils do
#   def remove_consecutive_duplicates(list) do
#     Enum.dedup(list)
#   end
# end

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

defmodule CaesarCipher do
  defp set_map(map, range, key) do
    org = Enum.map(range, &List.to_string([&1]))
    {a, b} = Enum.split(org, key)
    Enum.zip(org, b ++ a) |> Enum.into(map)
  end

  def encode(text, key) do
    map = Map.new() |> set_map(?a..?z, key) |> set_map(?A..?Z, key)
    String.graphemes(text) |> Enum.map_join(fn c -> Map.get(map, c, c) end)
  end

  def decode(ciphertext, shift) do
    encode(ciphertext, 26 - shift)
  end
end

defmodule PhoneNumber do
  def letter_combinations(number_string) do
    number_map = %{
      "2" => ["a", "b", "c"],
      "3" => ["d", "e", "f"],
      "4" => ["g", "h", "i"],
      "5" => ["j", "k", "l"],
      "6" => ["m", "n", "o"],
      "7" => ["p", "q", "r", "s"],
      "8" => ["t", "u", "v"],
      "9" => ["w", "x", "y", "z"]
    }

    String.graphemes(number_string)
    |> Enum.reduce([""], fn char, combinations ->
      Enum.flat_map(combinations, fn combination ->
        Enum.map(number_map[char], &(combination <> &1))
      end)
    end)
  end
end

defmodule Anagram do
  def group(strings) do
    strings
    |> Enum.group_by(fn string ->
      string
      |> String.downcase()
      |> String.graphemes()
      |> Enum.sort()
    end)
    |> Enum.map(fn {key, values} ->
      {key |> Enum.join(""), values}
    end)
  end
end
