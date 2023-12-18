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

    %{corners: corners} =
      [List.last(instructions) | instructions]
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(
        %{coordinates: {0, 0}, corners: []},
        fn [{_prev_length, prev_direction}, {curr_length, curr_direction}], %{coordinates: {x, y}, corners: corners} ->
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
            corners: [{x, y, corner} | corners]
          }
        end
      )

    sorted_y_corners_pairs =
      corners
      |> Enum.group_by(fn {_, y, _} -> y end)
      |> Enum.map(fn {y, corners} ->
        {
          y,
          Enum.sort(corners, fn {x_left, _, _}, {x_right, _, _} ->
            x_left <= x_right
          end)
        }
      end)
      |> Enum.sort(fn {y_left, _}, {y_right, _} ->
        y_left <= y_right
      end)
      |> dbg()
      |> Enum.chunk_every(2, 1, :discard)

    # F.....7   #######
    # .......   #.....#
    # L.7....   ###...#
    # .......   ..#...#
    # .......   ..#...#
    # F.J.F.J   ###.###
    # .......   #...#..
    # L7..L.7   ##..###
    # .......   .#....#
    # .L....J   .######

    # ..F..7    ..####
    # ......    ..####
    # F.J...    ######
    # L....J    ######

    # ..F..7..  ..####..
    # ........  ..####..
    # F.J..L.7  ########
    # L......J  ########
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
