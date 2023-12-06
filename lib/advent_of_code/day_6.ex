defmodule AdventOfCode.Day6 do
  @moduledoc false

  def solve(input, part: 1) do
    input
    |> parse(part: 1)
    |> Stream.map(fn {time, distance} ->
      for i <- 1..(time - 1), (time - i) * i > distance, reduce: 0 do
        acc ->
          acc + 1
      end
    end)
    |> Enum.product()
  end

  def solve(input, part: 2) do
    {time, distance} = parse(input, part: 2)

    for i <- 1..(time - 1), (time - i) * i > distance, reduce: 0 do
      acc ->
        acc + 1
    end
  end

  def parse(input, part: 1) do
    [times, distances] =
      input
      |> String.trim()
      |> String.split("\n")

    times = times |> String.split(" ", trim: true) |> Enum.slice(1..-1) |> Enum.map(&String.to_integer/1)
    distances = distances |> String.split(" ", trim: true) |> Enum.slice(1..-1) |> Enum.map(&String.to_integer/1)

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
end
