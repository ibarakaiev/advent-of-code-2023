defmodule AdventOfCode.Day17 do
  @moduledoc false
  def solve(input, part: part) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.graphemes()
        |> Enum.map(&String.to_integer/1)
      end)

    height = length(grid)
    width = length(Enum.at(grid, 0))

    graph =
      for y <- 0..(height - 1), reduce: %{} do
        acc ->
          for x <- 0..(width - 1), reduce: acc do
            acc ->
              acc =
                if y < height - 1 do
                  acc
                  |> Map.put({x, y}, [{{x, y + 1}, at(grid, {x, y + 1})} | Map.get(acc, {x, y}) || []])
                  |> Map.put({x, y + 1}, [{{x, y}, at(grid, {x, y})} | Map.get(acc, {x, y + 1}) || []])
                else
                  acc
                end

              if x < width - 1 do
                acc
                |> Map.put({x, y}, [{{x + 1, y}, at(grid, {x + 1, y})} | Map.get(acc, {x, y}) || []])
                |> Map.put({x + 1, y}, [{{x, y}, at(grid, {x, y})} | Map.get(acc, {x + 1, y}) || []])
              else
                acc
              end
          end
      end

    distances =
      Enum.reduce(graph, Map.new(), fn {_k, v}, acc ->
        for {node, _distance} <- v, reduce: acc do
          acc ->
            Enum.reduce([:L, :D, :R, :U], acc, fn direction, acc ->
              Enum.reduce(0..3, acc, fn steps, acc ->
                Map.put(
                  acc,
                  %{node: node, direction: direction, steps: steps},
                  if(node == {0, 0}, do: 0, else: 1_000_000)
                )
              end)
            end)
        end
      end)

    priority_queue =
      distances
      |> Enum.reject(fn {%{steps: steps}, v} -> v != 0 or steps != 0 end)
      |> Enum.reduce(PriorityQueue.new(), fn {key, value}, priority_queue ->
        PriorityQueue.push(priority_queue, key, value)
      end)

    %{distances: distances, path: _path} =
      1
      |> Stream.iterate(&(&1 + 1))
      |> Enum.reduce_while(
        %{
          path: %{},
          distances: distances,
          priority_queue: priority_queue
        },
        fn _,
           %{
             path: path,
             distances: distances,
             priority_queue: priority_queue
           } = acc ->
          {popped, priority_queue} = PriorityQueue.pop(priority_queue)

          case popped do
            :empty ->
              {:halt, acc}

            {:value, %{node: current, direction: current_direction, steps: current_steps}} ->
              {:cont,
               for {neighbor, distance} <- graph[current],
                   reduce: %{path: path, distances: distances, priority_queue: priority_queue} do
                 %{path: path, distances: distances, priority_queue: priority_queue} = acc ->
                   neighbor_direction = get_direction(current, neighbor)

                   new_distance =
                     distances[%{node: current, direction: current_direction, steps: current_steps}] + distance

                   neighbor_steps = if(neighbor_direction == current_direction, do: current_steps + 1, else: 1)

                   if new_distance < distances[%{node: neighbor, direction: neighbor_direction, steps: neighbor_steps}] and
                        not opposite?(current_direction, neighbor_direction) do
                     if (part == 1 and neighbor_steps <= 3) or
                          (part == 2 and current_direction != neighbor_direction and current_steps >= 4) or
                          (part == 2 and current_direction == neighbor_direction and neighbor_steps <= 10) do
                       %{
                         path: Map.put(path, {neighbor, neighbor_direction}, {current, current_direction}),
                         distances:
                           Map.put(
                             distances,
                             %{node: neighbor, direction: neighbor_direction, steps: neighbor_steps},
                             new_distance
                           ),
                         priority_queue:
                           PriorityQueue.push(
                             priority_queue,
                             %{node: neighbor, direction: neighbor_direction, steps: neighbor_steps},
                             new_distance
                           )
                       }
                     else
                       acc
                     end
                   else
                     acc
                   end
               end}
          end
        end
      )

    Enum.reduce([:L, :D, :R, :U], 1_000_000, fn direction, acc ->
      Enum.reduce(0..max(width, height), acc, fn steps, acc ->
        case part do
          1 ->
            min(acc, distances[%{node: {width - 1, height - 1}, direction: direction, steps: steps}] || 1_000_000)

          2 ->
            if steps >= 4 do
              min(acc, distances[%{node: {width - 1, height - 1}, direction: direction, steps: steps}] || 1_000_000)
            else
              acc
            end
        end
      end)
    end)
  end

  def get_direction({x_1, y_1}, {x_2, y_2}) do
    case {x_2 - x_1, y_2 - y_1} do
      {diff_x, diff_y} when diff_x < 0 and diff_y == 0 -> :L
      {diff_x, diff_y} when diff_x > 0 and diff_y == 0 -> :R
      {diff_x, diff_y} when diff_x == 0 and diff_y > 0 -> :D
      {diff_x, diff_y} when diff_x == 0 and diff_y < 0 -> :U
    end
  end

  defp opposite?(direction_1, direction_2) do
    case direction_1 do
      :L -> direction_2 == :R
      :R -> direction_2 == :L
      :U -> direction_2 == :D
      :D -> direction_2 == :U
    end
  end

  def at(list, {x, y}) do
    Enum.at(Enum.at(list, y), x)
  end
end
