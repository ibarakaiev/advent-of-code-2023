defmodule AdventOfCode.Day11 do
  @moduledoc false

  def solve(input, part: part) do
    lines =
      String.split(input, "\n", trim: true)

    parsed_lines = Enum.map(lines, &String.graphemes/1)

    vertical_prefix_sum =
      parsed_lines |> get_prefix_sum(part: part) |> List.to_tuple()

    horizontal_prefix_sum =
      parsed_lines
      |> List.zip()
      |> Stream.map(&Tuple.to_list/1)
      |> get_prefix_sum(part: part)
      |> List.to_tuple()

    coordinates =
      lines
      |> Stream.with_index()
      |> Enum.reduce([], fn {line, i}, acc ->
        indices = ~r/\#/ |> Regex.scan(line, return: :index) |> List.flatten() |> Enum.map(&{elem(&1, 0), i})
        [indices | acc]
      end)
      |> List.flatten()

    for {{first_x, first_y}, {second_x, second_y}} <- pairs(coordinates), reduce: 0 do
      acc ->
        horizontal_distance = abs(elem(horizontal_prefix_sum, first_x) - elem(horizontal_prefix_sum, second_x))
        vertical_distance = abs(elem(vertical_prefix_sum, first_y) - elem(vertical_prefix_sum, second_y))

        acc + horizontal_distance + vertical_distance
    end
  end

  defp get_prefix_sum(matrix, part: part) do
    matrix
    |> Enum.reduce([0], fn line, [head | _tail] = acc ->
      if Enum.all?(line, &(&1 == ".")) do
        [head + if(part == 1, do: 2, else: 1_000_000) | acc]
      else
        [head + 1 | acc]
      end
    end)
    |> Enum.reverse()
  end

  defp pairs(list) do
    list
    |> Stream.with_index()
    |> Enum.flat_map(fn {x, i} ->
      list
      |> Enum.drop(i + 1)
      |> Enum.map(&{x, &1})
    end)
  end
end
