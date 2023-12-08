defmodule AdventOfCode.Day8 do
  @moduledoc false

  def solve(input, part: 1) do
    {instructions, graph} = parse(input)

    instructions
    |> Stream.cycle()
    |> Enum.reduce_while({1, "AAA"}, fn instruction, {index, current_node} ->
      next_node = graph[current_node][instruction]

      if next_node == "ZZZ" do
        {:halt, index}
      else
        {:cont, {index + 1, next_node}}
      end
    end)
  end

  def solve(input, part: 2) do
    {instructions, graph} = parse(input)

    starting_nodes = graph |> Map.keys() |> Enum.filter(&String.ends_with?(&1, "A"))

    starting_nodes
    |> Enum.map(fn starting_node ->
      instructions
      |> Stream.cycle()
      |> Enum.reduce_while({1, starting_node}, fn instruction, {index, current_node} ->
        next_node = graph[current_node][instruction]

        if String.ends_with?(next_node, "Z") do
          {:halt, index}
        else
          {:cont, {index + 1, next_node}}
        end
      end)
    end)
    |> lcm()
  end

  def parse(input) do
    [instructions | network] =
      String.split(input, "\n", trim: true)

    {String.graphemes(instructions),
     Enum.reduce(network, %{}, fn line, acc ->
       [source, destination] = String.split(line, " = ", trim: true)

       [left, right] = destination |> String.slice(1, String.length(destination) - 2) |> String.split(", ")

       Map.put(acc, source, %{"L" => left, "R" => right})
     end)}
  end

  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))

  def lcm(x, y) when is_integer(y) do
    Integer.floor_div(x * y, gcd(x, y))
  end

  def lcm(x, [head | tail]) do
    lcm(x, lcm(head, tail))
  end

  def lcm(x, []), do: x

  def lcm(x) when is_list(x) do
    [head | tail] = x
    lcm(head, tail)
  end
end
