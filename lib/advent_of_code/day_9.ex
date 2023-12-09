defmodule AdventOfCode.Day9 do
  @moduledoc false

  def solve(input, opts) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      sequence = line |> String.split(" ") |> Enum.map(&String.to_integer(&1))

      0
      |> Stream.iterate(&(&1 + 1))
      |> Enum.reduce_while([sequence], fn _, acc ->
        last_sequence = List.last(acc)

        if(Enum.all?(last_sequence, &(&1 == 0))) do
          {:halt, acc}
        else
          {:cont,
           acc ++
             [
               last_sequence
               |> Enum.chunk_every(2, 1, :discard)
               |> Enum.map(fn [a, b] -> b - a end)
             ]}
        end
      end)
      |> Enum.reverse()
      |> Enum.reduce(0, fn sequence, acc ->
        case Keyword.get(opts, :part) do
          1 -> acc + List.last(sequence)
          2 -> List.first(sequence) - acc
        end
      end)
    end)
    |> Enum.sum()
  end
end
