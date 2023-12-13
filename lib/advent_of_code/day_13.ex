defmodule AdventOfCode.Day13 do
  @moduledoc false
  def solve(input, part: 1) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn pattern ->
      lines = String.split(pattern, "\n", trim: true)

      height = length(lines)
      width = String.length(List.first(lines))

      case find_mirrors(lines, width) do
        [{{_, left_end}, {_, _}}] ->
          left_end + 1

        [] ->
          vertical_lines =
            lines
            |> Enum.map(&String.graphemes(&1))
            |> List.zip()
            |> Enum.map(fn tuple -> tuple |> Tuple.to_list() |> Enum.join("") end)

          # if no horizontal matches, must have a vertical match
          [{{_, left_end}, {_, _}}] = find_mirrors(vertical_lines, height)

          100 * (left_end + 1)
      end
    end)
    |> Enum.sum()
  end

  # returns i.e. [{{0, 0}, {1, 1}}, {{0, 1}, {2, 3}}, {{0, 2}, {3, 5}}, {{0, 3}, {4, 7}}, {{1, 4}, {5, 8}}, {{3, 5}, {6, 8}}]
  # for length = 9
  defp get_mirror_pairs(length) do
    for_result =
      for i <- 0..(length - 2), reduce: [] do
        acc ->
          left = {if(i * 2 + 1 >= length, do: i * 2 + 1 - length + 1, else: 0), i}
          right = {i + 1, if(i * 2 + 1 >= length, do: length - 1, else: i * 2 + 1)}

          [{left, right} | acc]
      end

    MapSet.new(for_result)
  end

  defp find_mirrors(lines, length) do
    for_result =
      for line <- lines, reduce: get_mirror_pairs(length) do
        acc ->
          subtract =
            for {{left_start, left_end}, {right_start, right_end}} = pair <- acc, reduce: [] do
              subtract ->
                if String.slice(line, left_start, left_end - left_start + 1) !=
                     line |> String.slice(right_start, right_end - right_start + 1) |> String.reverse() do
                  [pair | subtract]
                else
                  subtract
                end
            end

          MapSet.difference(acc, MapSet.new(subtract))
      end

    MapSet.to_list(for_result)
  end
end
