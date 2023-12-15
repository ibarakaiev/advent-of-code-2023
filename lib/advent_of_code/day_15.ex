defmodule AdventOfCode.Day15 do
  @moduledoc false
  def solve(input, part: 1) do
    input
    |> String.trim("\n")
    |> String.split(",", trim: true)
    |> Stream.map(fn step ->
      hash(step)
    end)
    |> Enum.sum()
  end

  def solve(input, part: 2) do
    input
    |> String.trim("\n")
    |> String.split(",", trim: true)
    |> Enum.reduce(%{}, fn step, acc ->
      if String.contains?(step, "-") do
        [left, _right] = String.split(step, "-")

        hash = hash(left)

        if Map.has_key?(acc, hash) do
          list = Map.get(acc, hash)

          existing_index = Enum.find_index(list, fn el -> elem(el, 0) == left end)

          if existing_index do
            Map.put(acc, hash, List.delete_at(list, existing_index))
          else
            acc
          end
        else
          acc
        end
      else
        [left, right] = String.split(step, "=")

        hash = hash(left)

        if Map.has_key?(acc, hash) do
          list = Map.get(acc, hash)

          existing_index = Enum.find_index(list, fn el -> elem(el, 0) == left end)

          if existing_index do
            Map.put(acc, hash, List.replace_at(list, existing_index, {left, String.to_integer(right)}))
          else
            Map.put(acc, hash, list ++ [{left, String.to_integer(right)}])
          end
        else
          Map.put(acc, hash, [{left, String.to_integer(right)}])
        end
      end
    end)
    |> Enum.map(fn {hash, list} ->
      list
      |> Enum.with_index()
      |> Enum.map(fn {{_, focal_length}, i} ->
        (i + 1) * focal_length
      end)
      |> Enum.sum()
      |> Kernel.*(hash + 1)
    end)
    |> Enum.sum()
  end

  defp hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      rem((acc + char) * 17, 256)
    end)
  end
end
