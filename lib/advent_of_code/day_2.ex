defmodule AdventOfCode.Day2 do
  @moduledoc false

  def solve(input, part: part) do
    case part do
      1 ->
        input
        |> common()
        |> Stream.map(fn {game, set} ->
          {game,
           Map.get(set, "red") <= 12 and Map.get(set, "green") <= 13 and
             Map.get(set, "blue") <= 14}
        end)
        # %{"Game 1" => true}
        |> Stream.filter(fn {_game, possible?} ->
          possible?
        end)
        |> Stream.flat_map(fn {game, _possible?} ->
          Regex.run(~r/\d+/, game)
        end)
        # ["1"]
        |> Stream.map(&String.to_integer(&1))
        # [1]
        |> Enum.sum()

      2 ->
        input
        |> common()
        |> Stream.map(fn {_game, set} ->
          Map.get(set, "red") * Map.get(set, "green") * Map.get(set, "blue")
        end)
        |> Enum.sum()
    end
  end

  defp common(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      line
      |> String.split(":")
      |> Enum.map(&String.trim(&1))
      |> List.to_tuple()

      # {"Game 1", "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"}
    end)
    |> Map.new()
    # %{"Game 1" => "3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green"}
    |> Enum.map(fn {game, sets} ->
      {
        game,
        sets
        |> String.split(";")
        |> Stream.map(&String.trim(&1))
        # ["3 blue, 4 red", "1 red, 2 green, 6 blue", "2 green"]
        |> Enum.map(fn set ->
          # "3 blue, 4 red"
          set
          |> String.split(",")
          |> Stream.map(fn entry ->
            entry
            |> String.split(" ", trim: true)
            |> Enum.reverse()
            |> List.to_tuple()
          end)
          |> Enum.map(fn {color, value} ->
            {color, String.to_integer(value)}
          end)
          |> Map.new()

          # %{"blue" => 3, "red" => 4}
        end)
        |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn set, acc ->
          Map.merge(set, acc, fn _color, set_count, acc_count -> max(set_count, acc_count) end)
        end)
        # %{"red" => 4, "green" => 2, "blue" => 6}
      }
    end)
  end
end
