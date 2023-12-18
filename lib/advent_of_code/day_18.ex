defmodule AdventOfCode.Day18 do
  @moduledoc false
  def solve(input, part: part) do
    %{grid: grid} =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(
        %{grid: MapSet.new([{0, 0}]), coordinates: {0, 0}},
        fn row, %{grid: grid, coordinates: {current_x, current_y}} ->
          [direction | [length | [hex]]] = String.split(row, " ", trim: true)

          {length, direction} =
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
                dbg(hex)
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

          Enum.reduce(
            1..length,
            %{grid: grid, coordinates: {current_x, current_y}},
            fn _offset, %{grid: grid, coordinates: {current_x, current_y}} ->
              new_coordinates = {current_x + elem(direction, 0), current_y + elem(direction, 1)}

              %{grid: MapSet.put(grid, new_coordinates), coordinates: new_coordinates}
            end
          )
        end
      )

    {{min_x, min_y}, {max_x, max_y}} =
      grid
      |> MapSet.to_list()
      |> Enum.reduce(
        {{100_000_000, 100_000_000}, {-100_000_000, -100_000_000}},
        fn {x, y}, {{min_x, min_y}, {max_x, max_y}} ->
          {{min(min_x, x), min(min_y, y)}, {max(max_x, x), max(max_y, y)}}
        end
      )

    for y <- min_y..max_y, reduce: 0 do
      total ->
        %{total: row_total} =
          for x <- min_x..max_x, reduce: %{total: 0, inside: false, opener: ""} do
            %{total: total, inside: inside, opener: opener} = acc ->
              if MapSet.member?(grid, {x, y}) do
                acc = %{acc | total: total + 1}

                case {MapSet.member?(grid, {x - 1, y}), MapSet.member?(grid, {x, y + 1}),
                      MapSet.member?(grid, {x + 1, y}), MapSet.member?(grid, {x, y - 1})} do
                  # 7
                  {true, true, false, false} ->
                    if opener == "F", do: %{acc | opener: ""}, else: %{acc | opener: "", inside: !inside}

                  # -
                  {true, false, true, false} ->
                    acc

                  # J
                  {true, false, false, true} ->
                    if opener == "L", do: %{acc | opener: ""}, else: %{acc | opener: "", inside: !inside}

                  # |
                  {false, true, false, true} ->
                    %{acc | inside: !inside}

                  # F
                  {false, true, true, false} ->
                    %{acc | opener: "F"}

                  # L
                  {false, false, true, true} ->
                    %{acc | opener: "L"}
                end
              else
                if inside,
                  do: %{acc | total: total + 1},
                  else: acc
              end
          end

        total + row_total
    end
  end
end
