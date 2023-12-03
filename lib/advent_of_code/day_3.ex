defmodule AdventOfCode.Day3 do
  @moduledoc false

  def solve(input, opts) do
    case Keyword.get(opts, :part) do
      1 ->
        {zipped, line_length} = common(input)

        zipped
        |> Stream.map(fn {prev, curr, next} ->
          ~r/\d+/
          |> Regex.scan(curr, return: :index)
          |> List.flatten()
          |> Stream.map(fn {index, length} ->
            start_index = max(0, index - 1)
            end_index = min(line_length, index + length)

            if Regex.match?(~r/[^\d.]/, String.slice(prev, start_index, end_index - start_index + 1)) or
                 Regex.match?(~r/[^\d.]/, String.slice(curr, start_index, end_index - start_index + 1)) or
                 Regex.match?(~r/[^\d.]/, String.slice(next, start_index, end_index - start_index + 1)) do
              curr
              |> String.slice(index, length)
              |> String.to_integer()
            else
              0
            end
          end)
          |> Enum.sum()
        end)
        |> Enum.sum()

      2 ->
        {zipped, line_length} = common(input)

        zipped
        |> Stream.flat_map(fn {prev, curr, next} ->
          ~r/\*/
          |> Regex.scan(curr, return: :index)
          |> List.flatten()
          |> Stream.map(fn {index, _length} ->
            Enum.flat_map([prev, curr, next], fn line ->
              ~r/\d+/
              |> Regex.scan(line, return: :index)
              |> List.flatten()
              |> Stream.filter(fn {number_index, number_length} ->
                max(0, number_index - 1) <= index and min(line_length, number_index + number_length) >= index
              end)
              |> Enum.map(fn {number_index, number_length} ->
                line
                |> String.slice(number_index, number_length)
                |> String.to_integer()
              end)
            end)
          end)
          |> Stream.filter(&(length(&1) == 2))
          |> Stream.map(&Enum.product(&1))
        end)
        |> Enum.sum()
    end
  end

  @doc """
  Maps the following input:

  467..114..
  ...*......
  ..35..633.

  Into a list of tuples of form {prev_line, current_line, next_line}, i.e.:

  [
    {"..........", "467..114..", "...*......"}
    {"467..114..", "...*......", "..35..633."},
    {"...*......, "..35..633.", ".........."}
  ]
  """
  defp common(input) do
    lines =
      input
      |> String.trim()
      |> String.split("\n")

    line_length = lines |> Enum.at(0) |> String.length()

    empty_line =
      "."
      |> List.duplicate(line_length)
      |> Enum.join("")

    prev_lines =
      [empty_line] ++ Enum.slice(lines, 0..(length(lines) - 2))

    next_lines =
      Enum.slice(lines, 1..(length(lines) - 1)) ++ [empty_line]

    {Enum.zip([prev_lines, lines, next_lines]), line_length}
  end
end
