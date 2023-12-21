defmodule AdventOfCode.Day21 do
  @moduledoc false
  def solve(input, steps \\ nil, part: part) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn row -> String.graphemes(row) end)

    {width, height} = {Enum.count(Enum.at(lines, 0)), Enum.count(lines)}

    steps =
      if is_nil(steps) do
        case part do
          1 -> 64
          2 -> 26_501_365
        end
      else
        steps
      end

    map =
      Enum.reduce(Enum.with_index(lines), %{}, fn {row, row_index}, acc ->
        Enum.reduce(Enum.with_index(row), acc, fn {cell, cell_index}, acc ->
          Map.put(acc, {cell_index, row_index}, cell)
        end)
      end)

    starting_coordinates = map |> Enum.find(fn {_, cell} -> cell == "S" end) |> elem(0)

    queue =
      Enum.reduce(1..steps, :queue.in({starting_coordinates, {0, 0}}, :queue.new()), fn _, queue ->
        1
        |> Stream.iterate(&(&1 + 1))
        |> Enum.reduce_while({queue, :queue.new(), MapSet.new()}, fn _, {old_queue, new_queue, map_set} ->
          case :queue.out(old_queue) do
            {:empty, _old_queue} ->
              {:halt, new_queue}

            {{:value, {{x, y}, {x_level, y_level}}}, old_queue} ->
              {new_queue, map_set} =
                Enum.reduce(
                  [
                    {x + 1, y},
                    {x - 1, y},
                    {x, y + 1},
                    {x, y - 1}
                  ],
                  {new_queue, map_set},
                  fn {x, y}, {new_queue, map_set} ->
                    case part do
                      1 ->
                        if MapSet.member?(map_set, {{x, y}, {0, 0}}) or map[{x, y}] == "#" or x < 0 or x >= width or y < 0 or
                             y >= width do
                          {new_queue, map_set}
                        else
                          {:queue.in({{x, y}, {0, 0}}, new_queue), MapSet.put(map_set, {{x, y}, {0, 0}})}
                        end

                      2 ->
                        coordinates = convert({x, y}, {x_level, y_level}, width, height)
                        {{x, y}, _} = coordinates

                        if MapSet.member?(map_set, coordinates) or map[{x, y}] == "#" do
                          {new_queue, map_set}
                        else
                          {:queue.in(coordinates, new_queue), MapSet.put(map_set, coordinates)}
                        end
                    end
                  end
                )

              {:cont, {old_queue, new_queue, map_set}}
          end
        end)
      end)

    :queue.len(queue)
  end

  def convert({x, y}, {x_level, y_level}, width, height) do
    case {x, y} do
      {x, y} when x < 0 ->
        {{x + width, y}, {x_level - 1, y_level}}

      {x, y} when x >= width ->
        {{x - width, y}, {x_level + 1, y_level}}

      {x, y} when y < 0 ->
        {{x, y + height}, {x_level, y_level - 1}}

      {x, y} when y >= height ->
        {{x, y - height}, {x_level, y_level + 1}}

      _ ->
        {{x, y}, {x_level, y_level}}
    end
  end

  def print(map, queue, width, height) do
    map_set = queue |> :queue.to_list() |> MapSet.new()

    lines =
      for y <- 0..(height - 1), reduce: [] do
        acc ->
          for_result =
            for x <- 0..(width - 1), reduce: [] do
              line ->
                if MapSet.member?(map_set, {x, y}) do
                  line ++ ["O"]
                else
                  line ++ [map[{x, y}]]
                end
            end

          acc ++ [Enum.join(for_result, "")]
      end

    IO.puts("\n" <> Enum.join(lines, "\n"))
  end
end
