defmodule AdventOfCode.Day18 do
  @moduledoc false
  def solve(input, part: part) do
    instructions =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        [direction | [length | [hex]]] = String.split(row, " ", trim: true)

        case part do
          1 ->
            length = String.to_integer(length)

            direction =
              case direction do
                "L" -> {-1, 0}
                "D" -> {0, 1}
                "R" -> {1, 0}
                "U" -> {0, -1}
              end

            {length, direction}

          2 ->
            {length, _} = Integer.parse(String.slice(hex, 2..(String.length(hex) - 3)), 16)

            direction =
              case Integer.parse(String.slice(hex, (String.length(hex) - 2)..(String.length(hex) - 2)), 16) do
                {0, _} -> {1, 0}
                {1, _} -> {0, 1}
                {2, _} -> {-1, 0}
                {3, _} -> {0, -1}
              end

            {length, direction}
        end
      end)

    %{corners: corners, outline: outline} =
      [List.last(instructions) | instructions]
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(
        %{coordinates: {0, 0}, corners: [], outline: 0},
        fn [{_prev_length, prev_direction}, {curr_length, curr_direction}],
           %{coordinates: {x, y}, corners: corners, outline: outline} ->
          corner =
            case {direction_as_letter(prev_direction), direction_as_letter(curr_direction)} do
              {"L", "U"} -> "L"
              {"L", "D"} -> "F"
              {"R", "U"} -> "J"
              {"R", "D"} -> "7"
              {"U", "R"} -> "F"
              {"U", "L"} -> "7"
              {"D", "R"} -> "L"
              {"D", "L"} -> "J"
            end

          %{
            coordinates: {x + elem(curr_direction, 0) * curr_length, y + elem(curr_direction, 1) * curr_length},
            corners: [{x, y, corner} | corners],
            outline: abs(elem(curr_direction, 0) * curr_length) + abs(elem(curr_direction, 1) * curr_length) + outline
          }
        end
      )

    {_, area} =
      corners
      |> Enum.group_by(fn {_, y, _} -> y end)
      |> Enum.map(fn {y, corners} ->
        {
          y,
          Enum.map(corners, fn {x, _y, symbol} -> {x, symbol} end)
        }
      end)
      |> Enum.sort(fn {y_left, _}, {y_right, _} ->
        y_left <= y_right
      end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(
        {%{}, 0},
        fn [{current_y, current_corners}, {next_y, _next_corners}], {current_line, acc} ->
          corners_with_vertical_edges =
            current_line
            |> Map.merge(Map.new(current_corners))
            |> Enum.sort(fn {x_left, _}, {x_right, _} -> x_left <= x_right end)

          %{total: area_on_the_corner_line} =
            Enum.reduce(
              corners_with_vertical_edges,
              %{inside: false, total: 0, opener: "", prev_x: 0},
              fn {x, corner}, %{inside: inside, total: total, opener: opener, prev_x: prev_x} = acc ->
                acc =
                  case corner do
                    "L" ->
                      %{acc | opener: "L"}

                    "F" ->
                      %{acc | opener: "F"}

                    "7" ->
                      if opener == "F" do
                        %{acc | opener: ""}
                      else
                        %{acc | opener: "", inside: !inside}
                      end

                    "J" ->
                      if opener == "L" do
                        %{acc | opener: ""}
                      else
                        %{acc | opener: "", inside: !inside}
                      end

                    "|" ->
                      %{acc | inside: !inside}
                  end

                if inside and opener != "F" and opener != "L" do
                  %{acc | total: total + x - prev_x - 1, prev_x: x}
                else
                  %{acc | prev_x: x}
                end
              end
            )

          # construct a new line for the empty lines, based on the previous empty line and the current line
          updates =
            Map.new(
              for {x, corner} <- current_corners do
                case corner do
                  "F" -> {x, "|"}
                  "7" -> {x, "|"}
                  "J" -> if current_line[x] == "|", do: {x, "X"}, else: {x, "|"}
                  "L" -> if current_line[x] == "|", do: {x, "X"}, else: {x, "|"}
                end
              end
            )

          updated_line =
            current_line
            |> Map.merge(updates)
            |> Enum.reject(fn {_k, v} -> v == "X" end)
            |> Enum.sort(fn {k_left, _v_left}, {k_right, _v_right} -> k_left < k_right end)

          area_on_an_empty_line =
            updated_line
            |> Enum.chunk_every(2, 2)
            |> Enum.map(fn [{x_left, _}, {x_right, _}] -> x_right - x_left - 1 end)
            |> Enum.sum()

          {Map.new(updated_line), acc + area_on_the_corner_line + (next_y - current_y - 1) * area_on_an_empty_line}
        end
      )

    area + outline
  end

  defp direction_as_letter({offset_x, offset_y}) do
    case {offset_x, offset_y} do
      {-1, 0} -> "L"
      {0, 1} -> "D"
      {1, 0} -> "R"
      {0, -1} -> "U"
    end
  end
end
