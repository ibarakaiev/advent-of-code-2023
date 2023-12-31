defmodule AdventOfCode.Day12 do
  @moduledoc false

  def solve(input, part: part) do
    input
    |> String.split("\n", trim: true)
    |> Task.async_stream(fn line ->
      [row, counts] = String.split(line, " ", trim: true, parts: 2)

      sequence =
        row
        |> String.graphemes()
        |> Enum.chunk_by(& &1)
        |> Enum.map(fn chunk ->
          if Enum.any?(chunk, &(&1 == "?")), do: chunk, else: Enum.join(chunk, "")
        end)
        |> List.flatten()

      counts = ~r/\d+/ |> Regex.scan(counts) |> List.flatten() |> Enum.map(&String.to_integer/1)

      {sequence, counts} =
        case part do
          1 ->
            {sequence, counts}

          2 ->
            {
              [sequence] |> List.duplicate(5) |> Enum.intersperse("?") |> List.flatten(),
              counts |> List.duplicate(5) |> List.flatten()
            }
        end

      total_arrangements(sequence, counts, 1)
    end)
    |> Enum.reduce(0, fn {:ok, total}, acc -> acc + total end)
  end

  defp total_arrangements(sequence, counts, acc, inside? \\ false)

  defp total_arrangements([sequence_head | sequence_tail] = sequence, [count_head | count_tail] = counts, acc, inside?) do
    case Process.get({sequence, counts}) do
      nil ->
        if length(sequence) < length(counts) do
          # impossible to have more groups than chunks
          memoize({sequence, counts}, 0)
        else
          cond do
            String.contains?(sequence_head, ".") ->
              if inside? do
                # group is incomplete
                memoize({sequence, counts}, 0)
              else
                memoize(
                  {sequence, counts},
                  acc * total_arrangements(sequence_tail, counts, acc, false)
                )
              end

            String.contains?(sequence_head, "#") ->
              cond do
                count_head < String.length(sequence_head) ->
                  # group is incomplete
                  memoize({sequence, counts}, 0)

                count_head == String.length(sequence_head) ->
                  memoize(
                    {sequence, counts},
                    if length(sequence_tail) > 0 do
                      # need to skip to ensure no two groups merge
                      # (note that it's not possible for the next chunk to contain '#'
                      # because of how the input is parsed)
                      acc * total_arrangements(tl(sequence_tail), count_tail, acc)
                    else
                      acc
                    end
                  )

                count_head > String.length(sequence_head) ->
                  memoize(
                    {sequence, counts},
                    if length(sequence_tail) > 0 do
                      acc *
                        total_arrangements(
                          sequence_tail,
                          [count_head - String.length(sequence_head) | count_tail],
                          acc,
                          true
                        )
                    else
                      0
                    end
                  )
              end

            sequence_head == "?" ->
              # we can either fill it in or skip

              count_if_filled =
                if length(sequence_tail) > 0 do
                  next_chunk = List.first(sequence_tail)

                  cond do
                    String.contains?(next_chunk, ".") and count_head > 1 ->
                      # can't fill, otherwise the group will get split
                      0

                    String.contains?(next_chunk, "#") and count_head == 1 ->
                      # can't fill, otherwise the group will exceed capacity
                      0

                    String.contains?(next_chunk, "?") and count_head == 1 ->
                      # have to skip one, otherwise two groups will merge
                      total_arrangements(tl(sequence_tail), count_tail, acc, false)

                    count_head == 1 ->
                      if length(sequence_tail) > 0 do
                        total_arrangements(tl(sequence_tail), count_tail, acc, false)
                      else
                        acc
                      end

                    true ->
                      total_arrangements(sequence_tail, [count_head - 1 | count_tail], acc, true)
                  end
                else
                  if count_head == 1 do
                    1
                  else
                    0
                  end
                end

              count_if_skipped =
                if inside? do
                  # can't skip if inside a group
                  0
                else
                  total_arrangements(sequence_tail, counts, acc, inside?)
                end

              memoize({sequence, counts}, acc * (count_if_skipped + count_if_filled))
          end
        end

      result ->
        result
    end
  end

  defp total_arrangements([], [], _acc, _inside?), do: 1
  defp total_arrangements([], _counts, _acc, _inside?), do: 0

  defp total_arrangements(sequence, [], _acc, _inside?) do
    if Enum.any?(sequence, &String.contains?(&1, "#")) do
      0
    else
      1
    end
  end

  defp memoize({sequence, counts}, total) do
    Process.put({sequence, counts}, total)
    total
  end
end
