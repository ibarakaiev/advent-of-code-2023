defmodule AdventOfCode.Day4 do
  @moduledoc false

  def solve(input, part: 1) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      [_card, numbers] = String.split(line, ":")

      trunc(:math.pow(2, get_total_winning_numbers(numbers) - 1))
    end)
    |> Enum.sum()
  end

  def solve(input, part: 2) do
    lines =
      input
      |> String.trim()
      |> String.split("\n")

    map =
      lines
      |> Stream.map(fn line ->
        [_card, numbers] = String.split(line, ":")

        get_total_winning_numbers(numbers)
      end)
      |> Stream.with_index()
      |> Stream.map(fn {total_winning_numbers, index} ->
        {index, %{total_copies: 1, total_winning_numbers: total_winning_numbers}}
      end)
      |> Map.new()

    for_result =
      for i <- 0..(length(lines) - 1), reduce: map do
        acc ->
          if acc[i][:total_winning_numbers] > 0 do
            for j <- 1..acc[i][:total_winning_numbers], reduce: acc do
              acc ->
                %{
                  acc
                  | (i + j) => %{
                      acc[i + j]
                      | total_copies: acc[i + j][:total_copies] + acc[i][:total_copies]
                    }
                }
            end
          else
            acc
          end
      end

    for_result
    |> Stream.map(fn {_key, value} ->
      Map.get(value, :total_copies)
    end)
    |> Enum.sum()
  end

  # converts the list "1 2 3 | 3 4 5" into two lists
  # and finds the length of their intersection using Kernel.--/2
  defp get_total_winning_numbers(numbers) do
    [winning_numbers, numbers_you_have] =
      numbers
      |> String.split("|")
      |> Enum.map(fn list ->
        ~r/\d+/
        |> Regex.scan(list)
        |> List.flatten()
        |> Enum.map(fn number ->
          String.trim(number)
        end)
      end)

    length(winning_numbers -- winning_numbers -- numbers_you_have)
  end
end
