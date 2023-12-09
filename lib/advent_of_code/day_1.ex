defmodule AdventOfCode.Day1 do
  @moduledoc false

  def solve(input, part: part) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      case_result =
        case part do
          1 -> ~r/\d/
          2 -> ~r/one|two|three|four|five|six|seven|eight|nine|\d/
        end

      case_result
      |> Regex.scan(String.trim(line))
      |> Stream.map(&{&1, &1})
      |> Enum.reduce(fn {_el_1, el_2}, {acc_1, _acc_2} -> {acc_1, el_2} end)
      |> Tuple.to_list()
      |> Stream.map(fn [digit] ->
        case digit do
          "one" -> "1"
          "two" -> "2"
          "three" -> "3"
          "four" -> "4"
          "five" -> "5"
          "six" -> "6"
          "seven" -> "7"
          "eight" -> "8"
          "nine" -> "9"
          digit -> digit
        end
      end)
      |> Enum.join()
    end)
    |> Stream.map(&String.to_integer(&1))
    |> Enum.sum()
  end
end
