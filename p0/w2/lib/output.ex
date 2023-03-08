defmodule Output do
  def start do
    # minimal (10)
    IO.puts(Prime.is_prime?(9))

    IO.puts(Cylinder.area(3, 4))

    IO.inspect(ListUtils.reverse([1, 2, 4, 8, 4]))

    IO.inspect(ListUtils.sum_of_unique_elements([1, 2, 4, 8, 4, 4, 4, 2]))

    IO.inspect(ListUtils.extract_random_elements([1, 2, 4, 8, 4], 3))

    IO.inspect(Fibonacci.n_fibonacci(10))

    dict = %{:mama => "mother", :papa => "father", :baby => "child", :mi_casa => "home"}
    original_string = "mama is with papa and baby at mi_casa"
    IO.puts(Translator.translate(dict, original_string))

    IO.puts(NumberUtils.smallest_number(4, 5, 3))
    IO.puts(NumberUtils.smallest_number(0, 3, 4))

    IO.inspect(ListUtils.rotate_left([1, 2, 5, 10, 4, 5, 2], 4))

    IO.inspect(PythagoreanTriplets.find())

    # main (5)
    IO.inspect(ListUtils.remove_consecutive_duplicates([1, 2, 2, 2, 4, 8, 8, 4, 3]))

    IO.inspect(KeyboardRow.line_words(["Hello", "Alaska", "Dad", "Peace", "qwer", "hslgfq"]))

    IO.puts(CaesarCipher.encode("lorem", 3))
    IO.puts(CaesarCipher.decode("oruhp", 3))

    IO.inspect(PhoneNumber.letter_combinations("99"))

    IO.inspect(Anagram.group(["eat", "tea", "tan", "ate", "nat", "bat"]))

    # bonus (3)
    IO.inspect(CommonPrefix.common_prefix(["flower", "flow", "flight"]))
    IO.inspect(CommonPrefix.common_prefix(["alpha", "beta", "gamma"]))

    IO.puts(RomanNumeral.encode(13))

    IO.inspect(PrimeFactorization.prime_factors(42), charlists: :as_lists)
  end
end
