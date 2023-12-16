defmodule AdventOfCode.Day16 do
  @moduledoc false
  def solve(input, part: 1) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    Process.put(:memo, MapSet.new())

    Process.put(
      :energy_grid,
      "."
      |> List.duplicate(width(grid))
      |> List.duplicate(height(grid))
    )

    cast(grid, {0, 0}, direction: :R)

    total()
  end

  def solve(input, part: 2) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)

    horizontal_beams =
      for y <- 0..height(grid), reduce: [] do
        acc ->
          acc = [{{0, y}, :R} | acc]
          [{{width(grid) - 1, y}, :L} | acc]
      end

    vertical_beams =
      for x <- 0..width(grid), reduce: [] do
        acc ->
          acc = [{{x, 0}, :D} | acc]
          [{{x, height(grid) - 1}, :U} | acc]
      end

    (horizontal_beams ++ vertical_beams)
    |> Task.async_stream(fn {{start_x, start_y}, direction} ->
      Process.put(:memo, MapSet.new())

      Process.put(:energy_grid, "." |> List.duplicate(width(grid)) |> List.duplicate(height(grid)))

      cast(grid, {start_x, start_y}, direction: direction)

      total()
    end)
    |> Enum.reduce(0, fn {:ok, total}, acc -> max(total, acc) end)
  end

  def cast(grid, {start_x, start_y}, direction: direction) do
    if start_x >= 0 and start_x < width(grid) and start_y >= 0 and start_y < height(grid) and
         not MapSet.member?(Process.get(:memo), {{start_x, start_y}, direction}) do
      # cast a ray
      {end_x, end_y} =
        Enum.reduce_while(
          grid,
          {start_x, start_y},
          fn _, {acc_x, acc_y} ->
            Process.put(:energy_grid, replace_at(Process.get(:energy_grid), {acc_x, acc_y}, "#"))
            Process.put(:memo, MapSet.put(Process.get(:memo), {{acc_x, acc_y}, direction}))

            case at(grid, {acc_x, acc_y}) do
              "." ->
                cont_or_halt(grid, {acc_x + x_direction(direction), acc_y + y_direction(direction)})

              "-" ->
                if horizontal?(direction) do
                  cont_or_halt(grid, {acc_x + x_direction(direction), acc_y})
                else
                  {:halt, {acc_x, acc_y}}
                end

              "|" ->
                if horizontal?(direction) do
                  {:halt, {acc_x, acc_y}}
                else
                  cont_or_halt(grid, {acc_x, acc_y + y_direction(direction)})
                end

              _ ->
                {:halt, {acc_x, acc_y}}
            end
          end
        )

      # next steps for the ray
      if end_x >= 0 and end_x < width(grid) and end_y >= 0 and end_y < height(grid) do
        case at(grid, {end_x, end_y}) do
          "|" ->
            if horizontal?(direction) do
              cast(grid, {end_x, end_y - 1}, direction: :U)
              cast(grid, {end_x, end_y + 1}, direction: :D)
            else
              raise "unreachable"
            end

          "-" ->
            if horizontal?(direction) do
              raise "unreachable"
            else
              cast(grid, {end_x - 1, end_y}, direction: :L)
              cast(grid, {end_x + 1, end_y}, direction: :R)
            end

          "/" ->
            case direction do
              :R -> cast(grid, {end_x, end_y - 1}, direction: :U)
              :L -> cast(grid, {end_x, end_y + 1}, direction: :D)
              :U -> cast(grid, {end_x + 1, end_y}, direction: :R)
              :D -> cast(grid, {end_x - 1, end_y}, direction: :L)
            end

          "\\" ->
            case direction do
              :R -> cast(grid, {end_x, end_y + 1}, direction: :D)
              :L -> cast(grid, {end_x, end_y - 1}, direction: :U)
              :U -> cast(grid, {end_x - 1, end_y}, direction: :L)
              :D -> cast(grid, {end_x + 1, end_y}, direction: :R)
            end

          nil ->
            nil
        end
      end
    end
  end

  def total do
    for row <- Process.get(:energy_grid), reduce: 0 do
      acc ->
        acc + Enum.count(row, &(&1 == "#"))
    end
  end

  def cont_or_halt(grid, {x, y}) do
    if x < 0 or x >= width(grid) or y < 0 or y >= height(grid) do
      {:halt, {x, y}}
    else
      {:cont, {x, y}}
    end
  end

  def x_direction(direction) do
    case direction do
      :L -> -1
      :R -> 1
      _ -> 0
    end
  end

  def y_direction(direction) do
    case direction do
      :U -> -1
      :D -> 1
      _ -> 0
    end
  end

  def horizontal?(direction) do
    direction == :L or direction == :R
  end

  def height(grid) do
    length(grid)
  end

  def width(grid) do
    grid |> Enum.at(0) |> length()
  end

  defp replace_at(list, {x, y}, value) do
    inner_list = Enum.at(list, y)
    new_inner_list = List.replace_at(inner_list, x, value)
    List.replace_at(list, y, new_inner_list)
  end

  def at(list, {x, y}) do
    Enum.at(Enum.at(list, y), x)
  end
end
