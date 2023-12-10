defmodule AdventOfCode.Day10 do
  @moduledoc false

  def solve(input, part: _part) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes(&1))

    {s_x, s_y} =
      Enum.reduce_while(map, {0, 0}, fn line, {x, y} ->
        if Enum.find_index(line, &(&1 == "S")) do
          {:halt, {Enum.find_index(line, &(&1 == "S")), y}}
        else
          {:cont, {x, y + 1}}
        end
      end)

    starting_coordinates =
      Enum.reduce_while(["L", "D", "R", "U"], nil, fn direction, _acc ->
        case_result =
          case direction do
            "L" ->
              symbol = Enum.at(Enum.at(map, s_y), s_x - 1)

              if symbol == "-" or symbol == "L" or symbol == "F" do
                {:halt, {s_x - 1, s_y}}
              end

            "D" ->
              symbol = Enum.at(Enum.at(map, s_y + 1), s_x)

              if symbol == "|" or symbol == "L" or symbol == "J" do
                {:halt, {s_x, s_y + 1}}
              end

            "R" ->
              symbol = Enum.at(Enum.at(map, s_y), s_x + 1)

              if symbol == "-" or symbol == "J" or symbol == "7" do
                {:halt, {s_x + 1, s_y}}
              end

            "U" ->
              symbol = Enum.at(Enum.at(map, s_y - 1), s_x)

              if symbol == "|" or symbol == "F" or symbol == "7" do
                {:halt, {s_x, s_y + 1}}
              end
          end

        case case_result do
          nil -> {:cont, nil}
          result -> result
        end
      end)

    1
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while(
      %{
        length: 1,
        prev_coordinates: {s_x, s_y},
        current_coordinates: starting_coordinates
      },
      fn _,
         %{
           length: length,
           prev_coordinates: {prev_x, prev_y},
           current_coordinates: {curr_x, curr_y}
         } ->
        symbol = Enum.at(Enum.at(map, curr_y), curr_x)

        {next_x, next_y} =
          case symbol do
            "-" ->
              if {prev_x, prev_y} == {curr_x - 1, curr_y} do
                # right
                {curr_x + 1, curr_y}
              else
                # left
                {curr_x - 1, curr_y}
              end

            "|" ->
              if {prev_x, prev_y} == {curr_x, curr_y - 1} do
                # down
                {curr_x, curr_y + 1}
              else
                # up
                {curr_x, curr_y - 1}
              end

            "F" ->
              if {prev_x, prev_y} == {curr_x, curr_y + 1} do
                # right
                {curr_x + 1, curr_y}
              else
                # down
                {curr_x, curr_y + 1}
              end

            "7" ->
              if {prev_x, prev_y} == {curr_x, curr_y + 1} do
                # left
                {curr_x - 1, curr_y}
              else
                # down
                {curr_x, curr_y + 1}
              end

            "J" ->
              if {prev_x, prev_y} == {curr_x, curr_y - 1} do
                # left
                {curr_x - 1, curr_y}
              else
                # up
                {curr_x, curr_y - 1}
              end

            "L" ->
              if {prev_x, prev_y} == {curr_x, curr_y - 1} do
                # right
                {curr_x + 1, curr_y}
              else
                # up
                {curr_x, curr_y - 1}
              end
          end

        if Enum.at(Enum.at(map, next_y), next_x) == "S" do
          {:halt, length + 1}
        else
          {:cont,
           %{
             prev_coordinates: {curr_x, curr_y},
             current_coordinates: {next_x, next_y},
             length: length + 1
           }}
        end
      end
    )
    |> div(2)
  end
end
