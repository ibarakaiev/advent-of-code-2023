defmodule AdventOfCode.Day14 do
  @moduledoc false
  def solve(input, part: 1) do
    input
    |> String.split("\n", trim: true)
    |> roll(direction: :N)
    |> total()
  end

  def solve(input, part: 2) do
    input = String.split(input, "\n", trim: true)

    {_, list} =
      [:N, :W, :S, :E]
      # hardcoded hoping that 300 iterations is enough to converge
      |> List.duplicate(300)
      |> Enum.reduce({input, []}, fn directions, {acc, list} ->
        acc =
          Enum.reduce(directions, acc, fn direction, acc ->
            roll(acc, direction: direction)
          end)

        {acc, [total(acc) | list]}
      end)

    list = Enum.reverse(list)

    # hardcoded numbers hoping that the length of the cycle is under 50 and
    # it converges after around 100 iterations
    {offset, length} =
      Enum.reduce_while(100..200, nil, fn i, _ ->
        inner =
          Enum.reduce_while(2..50, nil, fn j, _ ->
            if Enum.slice(list, i, j) == Enum.slice(list, i + j, j) do
              {:halt, {i, j}}
            else
              {:cont, nil}
            end
          end)

        case inner do
          nil -> {:cont, nil}
          _ -> {:halt, inner}
        end
      end)

    # adjust the offset to the left until the sequence no longer matches
    # (otherwise we don't actually know when it starts repeating)
    offset =
      Enum.reduce_while(0..offset, offset, fn _, offset ->
        if Enum.slice(list, offset, length) != Enum.slice(list, offset + length, length) do
          {:halt, offset + 1}
        else
          {:cont, offset - 1}
        end
      end)

    Enum.at(list, offset + rem(1_000_000_000 - 1 - offset, length))
  end

  def roll(input, direction: direction) do
    rearranged = rearrange(input, direction: direction)

    rolled =
      Enum.map(rearranged, fn line ->
        line
        |> String.split("#")
        |> Enum.map_join("#", fn chunk ->
          chunk
          |> String.graphemes()
          |> Enum.sort(if direction == :N or direction == :W, do: :desc, else: :asc)
          |> Enum.join("")
        end)
      end)

    rearrange(rolled, direction: direction)
  end

  def rearrange(input, direction: direction) do
    if direction == :N or direction == :S do
      input
      |> Enum.map(&String.graphemes/1)
      |> List.zip()
      |> Enum.map(fn tuple -> tuple |> Tuple.to_list() |> Enum.join("") end)
    else
      input
    end
  end

  def total(input) do
    height = length(input)

    {total, _} =
      Enum.reduce(input, {0, height}, fn line, {total, load} ->
        {(line |> String.graphemes() |> Enum.count(&(&1 == "O"))) * load + total, load - 1}
      end)

    total
  end
end
