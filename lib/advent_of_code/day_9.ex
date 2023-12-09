defmodule AdventOfCode.Day9 do
  @moduledoc false

  def solve(input, part: part) do
    input
    |> String.split("\n", trim: true)
    |> Stream.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer(&1))
      |> Stream.unfold(fn sequence ->
        unless Enum.all?(sequence, &(&1 == 0)) do
          {sequence,
           sequence
           |> Stream.chunk_every(2, 1, :discard)
           |> Enum.map(fn [a, b] -> b - a end)}
        end
      end)
      |> Enum.reverse()
      |> Enum.reduce(0, fn sequence, acc ->
        case part do
          1 -> acc + List.last(sequence)
          2 -> List.first(sequence) - acc
        end
      end)
    end)
    |> Enum.sum()
  end
end
