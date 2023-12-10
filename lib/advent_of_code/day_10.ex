defmodule AdventOfCode.Day10 do
  @moduledoc false

  def solve(input, part: 1) do
    %{map: map, starting_coordinates: starting_coordinates, s_coordinates: {s_x, s_y}} = prepare(input)

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
        symbol = elem(elem(map, curr_y), curr_x)

        {next_x, next_y} = get_next_coordinate(symbol, {prev_x, prev_y}, {curr_x, curr_y})

        if elem(elem(map, next_y), next_x) == "S" do
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

  def solve(input, part: 2) do
    %{
      map: original_map,
      starting_coordinates: {starting_x, starting_y} = starting_coordinates,
      s_coordinates: {s_x, s_y},
      height: height,
      width: width
    } = prepare(input)

    updated_map =
      1..height
      |> Enum.map(fn _ -> "." |> List.duplicate(width) |> List.to_tuple() end)
      |> List.to_tuple()
      |> put_in_2d_tuple(
        starting_coordinates,
        elem(elem(original_map, starting_y), starting_x)
      )

    # get rid of garbage and infer S
    updated_map =
      1
      |> Stream.iterate(&(&1 + 1))
      |> Enum.reduce_while(
        %{
          updated_map: updated_map,
          prev_coordinates: {s_x, s_y},
          current_coordinates: starting_coordinates
        },
        fn _,
           %{
             updated_map: updated_map,
             prev_coordinates: {prev_x, prev_y},
             current_coordinates: {curr_x, curr_y}
           } ->
          symbol = elem(elem(original_map, curr_y), curr_x)

          {next_x, next_y} = get_next_coordinate(symbol, {prev_x, prev_y}, {curr_x, curr_y})

          if elem(elem(original_map, next_y), next_x) == "S" do
            {:halt,
             put_in_2d_tuple(
               updated_map,
               {s_x, s_y},
               case {get_direction({s_x, s_y}, {starting_x, starting_y}), get_direction({s_x, s_y}, {curr_x, curr_y})} do
                 {"L", "R"} -> "-"
                 {"L", "U"} -> "J"
                 {"L", "D"} -> "7"
                 {"U", "R"} -> "L"
                 {"D", "R"} -> "F"
               end
             )}
          else
            {:cont,
             %{
               prev_coordinates: {curr_x, curr_y},
               current_coordinates: {next_x, next_y},
               updated_map:
                 put_in_2d_tuple(
                   updated_map,
                   {next_x, next_y},
                   elem(elem(original_map, next_y), next_x)
                 )
             }}
          end
        end
      )
      |> Tuple.to_list()

    # cast a horizontal ray for each row
    updated_map
    |> Stream.map(fn row ->
      row = Tuple.to_list(row)

      %{inside: _, inner_points_count: inner_points_count, opener: _} =
        for symbol <- row,
            reduce: %{inside: false, inner_points_count: 0, opener: ""} do
          %{inside: inside, inner_points_count: inner_points_count, opener: opener} = acc ->
            case symbol do
              "." -> if inside, do: %{acc | inner_points_count: inner_points_count + 1}, else: acc
              "|" -> %{acc | inside: !inside}
              "L" -> %{acc | opener: "L"}
              "F" -> %{acc | opener: "F"}
              "7" -> if opener == "F", do: %{acc | opener: ""}, else: %{acc | opener: "", inside: !inside}
              "J" -> if opener == "L", do: %{acc | opener: ""}, else: %{acc | opener: "", inside: !inside}
              "-" -> acc
            end
        end

      inner_points_count
    end)
    |> Enum.sum()
  end

  # returns a parsed map, starting_coordinates (one of the two adjacent points to S that would work),
  # the coordinates of S, and dimensions of the grid
  defp prepare(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Stream.map(&String.graphemes(&1))

    {s_x, s_y} =
      Enum.reduce_while(map, {0, 0}, fn line, {x, y} ->
        if Enum.find_index(line, &(&1 == "S")) do
          {:halt, {Enum.find_index(line, &(&1 == "S")), y}}
        else
          {:cont, {x, y + 1}}
        end
      end)

    # convert to tuple to get a static array, otherwise it's a linked list
    # (we don't need Enumerable behaviour at this point)
    map = map |> Enum.map(&List.to_tuple(&1)) |> List.to_tuple()

    # I don't remember seeing if they have to be equal
    height = tuple_size(map)
    width = tuple_size(elem(map, 0))

    starting_coordinates =
      Enum.reduce_while(["L", "D", "R", "U"], nil, fn direction, _acc ->
        case_result =
          case direction do
            "L" ->
              if s_x - 1 >= 0 do
                symbol = elem(elem(map, s_y), s_x - 1)

                if symbol == "-" or symbol == "L" or symbol == "F" do
                  {:halt, {s_x - 1, s_y}}
                end
              end

            "D" ->
              if s_y + 1 < height do
                symbol = elem(elem(map, s_y + 1), s_x)

                if symbol == "|" or symbol == "L" or symbol == "J" do
                  {:halt, {s_x, s_y + 1}}
                end
              end

            "R" ->
              if s_x + 1 < width do
                symbol = elem(elem(map, s_y), s_x + 1)

                if symbol == "-" or symbol == "J" or symbol == "7" do
                  {:halt, {s_x + 1, s_y}}
                end
              end

            "U" ->
              if s_y - 1 >= 0 do
                symbol = elem(elem(map, s_y - 1), s_x)

                if symbol == "|" or symbol == "F" or symbol == "7" do
                  {:halt, {s_x, s_y + 1}}
                end
              end
          end

        case case_result do
          nil -> {:cont, nil}
          result -> result
        end
      end)

    %{map: map, starting_coordinates: starting_coordinates, s_coordinates: {s_x, s_y}, height: height, width: width}
  end

  defp get_next_coordinate(symbol, {prev_x, prev_y}, {curr_x, curr_y}) do
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
  end

  defp put_in_2d_tuple(map, {x, y}, elem) do
    inner_tuple = elem(map, y)
    new_inner_tuple = put_elem(inner_tuple, x, elem)
    put_elem(map, y, new_inner_tuple)
  end

  defp get_direction({x_1, y_1}, {x_2, y_2}) do
    case {x_2 - x_1, y_2 - y_1} do
      {diff_x, diff_y} when diff_x < 0 and diff_y == 0 -> "L"
      {diff_x, diff_y} when diff_x > 0 and diff_y == 0 -> "R"
      {diff_x, diff_y} when diff_x == 0 and diff_y > 0 -> "D"
      {diff_x, diff_y} when diff_x == 0 and diff_y < 0 -> "U"
    end
  end
end
