defmodule AdventOfCode.Day6 do
  @moduledoc false

  def solve(input, part: 1) do
    input
    |> parse(part: 1)
    |> Stream.map(fn {time, distance} ->
      number_of_ways(time, distance)
    end)
    |> Enum.product()
  end

  def solve(input, part: 2) do
    {time, distance} = parse(input, part: 2)

    number_of_ways(time, distance)
  end

  def parse(input, part: 1) do
    [times, distances] =
      input
      |> String.trim()
      |> String.split("\n")

    times = ~r/\d+/ |> Regex.scan(times) |> Enum.map(fn [time] -> String.to_integer(time) end)
    distances = ~r/\d+/ |> Regex.scan(distances) |> Enum.map(fn [time] -> String.to_integer(time) end)

    times
    |> Enum.zip(distances)
    |> Map.new()
  end

  def parse(input, part: 2) do
    [time, distance] =
      input
      |> String.trim()
      |> String.split("\n")

    time = ~r/\d+/ |> Regex.scan(time) |> List.flatten() |> Enum.join("") |> String.to_integer()
    distance = ~r/\d+/ |> Regex.scan(distance) |> List.flatten() |> Enum.join("") |> String.to_integer()

    {time, distance}
  end

  def number_of_ways(time, distance) do
    x_1 = (time + :math.sqrt(:math.pow(time, 2) - 4 * distance)) / 2
    x_2 = (time - :math.sqrt(:math.pow(time, 2) - 4 * distance)) / 2

    trunc(:math.floor(x_1 - 0.0001)) - trunc(:math.ceil(x_2 + 0.0001)) + 1
  end
end
