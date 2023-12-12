defmodule AdventOfCode.Day12 do
  @moduledoc false

  def solve(input, part: part) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Task.async_stream(fn {line, i} ->
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
              (sequence ++ ["?"]) |> List.duplicate(5) |> List.flatten() |> Enum.drop(-1),
              counts |> List.duplicate(5) |> List.flatten()
            }
        end

      table_name = String.to_atom("line_#{i}")
      :ets.new(table_name, [:set, :named_table, :public])
      total_arrangements(sequence, counts, 1, table_name)
    end)
    |> Enum.reduce(0, fn {:ok, total}, acc -> acc + total end)
  end

  defp total_arrangements(sequence, counts, acc, table_name, inside? \\ false)

  defp total_arrangements(
         [sequence_head | sequence_tail] = sequence,
         [count_head | count_tail] = counts,
         acc,
         table_name,
         inside?
       ) do
    case :ets.lookup(table_name, {sequence, counts}) do
      [{{_, _}, result}] ->
        result

      [] ->
        if length(sequence) < length(counts) do
          # impossible to have more groups than chunks
          memoize({sequence, counts}, 0, table_name)
        else
          cond do
            String.contains?(sequence_head, ".") ->
              if inside? do
                # group is incomplete
                memoize({sequence, counts}, 0, table_name)
              else
                memoize(
                  {sequence, counts},
                  acc * total_arrangements(sequence_tail, counts, acc, table_name, false),
                  table_name
                )
              end

            String.contains?(sequence_head, "#") ->
              cond do
                count_head < String.length(sequence_head) ->
                  # group is incomplete
                  memoize({sequence, counts}, 0, table_name)

                count_head == String.length(sequence_head) ->
                  memoize(
                    {sequence, counts},
                    if length(sequence_tail) > 0 do
                      # need to skip to ensure no two groups merge
                      # (note that it's not possible for the next chunk to contain '#'
                      # because of how the input is parsed)
                      acc * total_arrangements(tl(sequence_tail), count_tail, acc, table_name)
                    else
                      acc
                    end,
                    table_name
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
                          table_name,
                          true
                        )
                    else
                      0
                    end,
                    table_name
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
                      total_arrangements(tl(sequence_tail), count_tail, acc, table_name, false)

                    count_head == 1 ->
                      if length(sequence_tail) > 0 do
                        total_arrangements(tl(sequence_tail), count_tail, acc, table_name, false)
                      else
                        acc
                      end

                    true ->
                      total_arrangements(sequence_tail, [count_head - 1 | count_tail], acc, table_name, true)
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
                  total_arrangements(sequence_tail, counts, acc, table_name, inside?)
                end

              memoize({sequence, counts}, acc * (count_if_skipped + count_if_filled), table_name)
          end
        end
    end
  end

  defp total_arrangements([], [], _acc, _table_name, _inside?), do: 1
  defp total_arrangements([], _counts, _table_name, _acc, _inside?), do: 0

  defp total_arrangements(sequence, [], _table_name, _acc, _inside?) do
    if Enum.any?(sequence, &String.contains?(&1, "#")) do
      0
    else
      1
    end
  end

  defp memoize({sequence, counts}, total, table_name) do
    :ets.insert(table_name, {{sequence, counts}, total})

    total
  end
end
