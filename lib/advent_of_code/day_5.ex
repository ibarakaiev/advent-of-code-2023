defmodule AdventOfCode.Day5 do
  @moduledoc false

  @order [:seed, :soil, :fertilizer, :water, :light, :temperature, :humidity, :location]

  def solve(input, part: 1) do
    {seeds, graph} = parse(input)

    seeds
    |> Stream.map(fn seed ->
      Enum.reduce(0..(length(@order) - 2), seed, fn index, acc ->
        range_maps = graph[Enum.at(@order, index)][Enum.at(@order, index + 1)]

        for range_map <- range_maps,
            acc >= range_map.source_range_start and acc < range_map.source_range_start + range_map.range_length,
            reduce: acc do
          acc ->
            acc - range_map.source_range_start + range_map.destination_range_start
        end
      end)
    end)
    |> Enum.min()
  end

  def solve(input, part: 2) do
    {seeds, graph} = parse(input)

    seeds
    |> Stream.chunk_every(2)
    |> Stream.map(fn [seed_range_start, seed_range_length] ->
      seed_range_end = seed_range_start + seed_range_length - 1

      0..(length(@order) - 2)
      |> Enum.reduce([%{start: seed_range_start, end: seed_range_end}], fn index, acc ->
        range_maps = graph[Enum.at(@order, index)][Enum.at(@order, index + 1)]

        range_maps
        |> Enum.reduce(acc, fn range_map, acc ->
          Enum.flat_map(acc, fn seed_range ->
            # do not map a range that has already been mapped, since all
            # "maps" happen at the same time within a round
            if Map.has_key?(seed_range, :kind) and seed_range[:kind] == :mapped do
              [seed_range]
            else
              split_range(seed_range, range_map)
            end
          end)
        end)
        |> Enum.map(fn range ->
          Map.drop(range, [:kind])
        end)
      end)
      |> Stream.map(& &1[:start])
      |> Enum.min()
    end)
    |> Enum.min()
  end

  @doc """
  Returns

  {
    [79, 14, 55, 13],
    %{
      seed: %{
        soil: [
          %{range_length: 2, destination_range_start: 50, source_range_start: 98},
          ...
        ]
      },
      ...
    }
  }
  """
  def parse(input) do
    [seeds | maps] =
      String.split(input, "\n\n", trim: true)

    seeds =
      ~r/\d+/
      |> Regex.scan(
        seeds
        |> String.split(" ", parts: 2, trim: true)
        |> Enum.at(1)
      )
      |> List.flatten()
      |> Enum.map(&String.to_integer(&1))

    graph =
      Enum.reduce(maps, %{}, fn map, acc ->
        [map_name | ranges] = String.split(map, "\n", trim: true)

        map_name = map_name |> String.split(" ") |> Enum.at(0)

        [source, destination] = map_name |> String.split("-to-") |> Enum.map(&String.to_atom(&1))

        ranges =
          Enum.flat_map(ranges, fn range ->
            range
            |> String.split("\n", trim: true)
            |> Enum.map(fn range ->
              [destination_range_start, source_range_start, range_length] = String.split(range, " ")

              %{
                source_range_start: String.to_integer(source_range_start),
                destination_range_start: String.to_integer(destination_range_start),
                range_length: String.to_integer(range_length)
              }
            end)
          end)

        Map.put(acc, source, Map.put(%{}, destination, ranges))
      end)

    {seeds, graph}
  end

  @doc """
  Splits and maps a range based on a map, sorting the list at the end.
  """
  def split_range(input_range, map) do
    source_range_end = map.source_range_start + map.range_length - 1
    destination_range_end = map.destination_range_start + map.range_length - 1

    map = Map.put(map, :source_range_end, source_range_end)
    map = Map.put(map, :destination_range_end, destination_range_end)

    case {input_range.start, input_range.end} do
      {range_start, range_end} when range_start > source_range_end or range_end < map.source_range_start ->
        # No overlap
        [input_range]

      {range_start, range_end} ->
        # Determine the overlap with the source range
        overlap_start = max(range_start, map.source_range_start)
        overlap_end = min(range_end, source_range_end)

        # Calculate the offset for the destination range
        offset = overlap_start - map.source_range_start
        destination_start = map.destination_range_start + offset
        destination_end = destination_start + (overlap_end - overlap_start)

        ranges = [
          # Before overlap
          if(range_start < overlap_start, do: %{start: range_start, end: overlap_start - 1}),
          # Mapped range
          %{start: destination_start, end: destination_end, kind: :mapped},
          # After overlap
          if(range_end > overlap_end, do: %{start: overlap_end + 1, end: range_end})
        ]

        # Remove nil entries and sort the list
        ranges
        |> Enum.filter(&(&1 != nil))
        |> Enum.sort(&(&1.start <= &2.start))
    end
  end
end
