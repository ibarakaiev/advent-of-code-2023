defmodule AdventOfCode.Day20 do
  @moduledoc false
  def solve(input, part: 1) do
    circuit = parse(input)

    %{total_low_pulses: total_low_pulses, total_high_pulses: total_high_pulses} =
      Enum.reduce(
        1..1000,
        %{total_low_pulses: 0, total_high_pulses: 0, circuit: circuit},
        fn _, %{total_low_pulses: total_low_pulses, total_high_pulses: total_high_pulses, circuit: circuit} ->
          %{circuit: circuit, total_low_pulses: additional_low_pulses, total_high_pulses: additional_high_pulses} =
            push_button(circuit)

          %{
            circuit: circuit,
            total_low_pulses: total_low_pulses + additional_low_pulses,
            total_high_pulses: total_high_pulses + additional_high_pulses
          }
        end
      )

    total_high_pulses * total_low_pulses
  end

  def solve(input, part: 2) do
    circuit = parse(input)

    common_nodes =
      1..3
      |> Enum.reduce(["rx"], fn _, acc -> Enum.flat_map(acc, fn node -> Map.keys(circuit[node].parents) end) end)
      |> Enum.map(fn v -> {v, nil} end)
      |> Map.new()

    1
    |> Stream.iterate(&(&1 + 1))
    |> Stream.with_index(1)
    |> Enum.reduce_while({circuit, common_nodes}, fn {_, i}, {circuit, values} ->
      %{circuit: circuit} = push_button(circuit)

      values =
        Enum.reduce(values, values, fn {k, v}, values ->
          if is_nil(v) and Enum.all?(circuit[k].parents, fn {_, pulse} -> pulse == :low end) do
            Map.put(values, k, i)
          else
            values
          end
        end)

      if Enum.all?(values, fn {_, v} -> v end) do
        {:halt, values}
      else
        {:cont, {circuit, values}}
      end
    end)
    |> Enum.map(fn {_k, v} -> v end)
    |> lcm()
  end

  def push_button(circuit) do
    1
    |> Stream.iterate(&(&1 + 1))
    |> Enum.reduce_while(
      %{
        circuit: circuit,
        queue: :queue.in({"broadcaster", nil}, :queue.new()),
        total_low_pulses: 1,
        total_high_pulses: 0
      },
      fn _, %{circuit: circuit, queue: queue} = acc ->
        case :queue.out(queue) do
          {{:value, {source, sender}}, queue} ->
            acc =
              case circuit[source].kind do
                :broadcaster ->
                  for destination <- circuit[source].destination,
                      reduce: %{acc | queue: queue} do
                    %{circuit: circuit, total_low_pulses: total_low_pulses, queue: queue} = acc ->
                      %{
                        acc
                        | circuit:
                            put_in(
                              circuit,
                              [destination, :parents, source],
                              :low
                            ),
                          total_low_pulses: total_low_pulses + 1,
                          queue: :queue.in({destination, source}, queue)
                      }
                  end

                :flip_flop ->
                  state = circuit[source].state

                  case circuit[source].parents[sender] do
                    :low ->
                      for destination <- circuit[source].destination,
                          reduce: %{
                            acc
                            | circuit: put_in(circuit, [source, :state], if(state == :off, do: :on, else: :off)),
                              queue: queue
                          } do
                        %{
                          circuit: circuit,
                          total_high_pulses: total_high_pulses,
                          total_low_pulses: total_low_pulses,
                          queue: queue
                        } =
                            acc ->
                          %{
                            acc
                            | circuit:
                                put_in(
                                  circuit,
                                  [destination, :parents, source],
                                  if(state == :off, do: :high, else: :low)
                                ),
                              total_high_pulses: total_high_pulses + if(state == :off, do: 1, else: 0),
                              total_low_pulses: total_low_pulses + if(state == :off, do: 0, else: 1),
                              queue: :queue.in({destination, source}, queue)
                          }
                      end

                    :high ->
                      %{acc | queue: queue}
                  end

                :conjunction ->
                  total_inputs = circuit[source].parents |> Map.keys() |> Enum.count()
                  total_high_inputs = Enum.count(circuit[source].parents, fn {_k, v} -> v == :high end)

                  for destination <- circuit[source].destination, reduce: %{acc | queue: queue} do
                    %{
                      circuit: circuit,
                      total_low_pulses: total_low_pulses,
                      total_high_pulses: total_high_pulses,
                      queue: queue
                    } ->
                      %{
                        acc
                        | circuit:
                            put_in(
                              circuit,
                              [destination, :parents, source],
                              if(total_inputs == total_high_inputs, do: :low, else: :high)
                            ),
                          total_low_pulses: total_low_pulses + if(total_inputs == total_high_inputs, do: 1, else: 0),
                          total_high_pulses: total_high_pulses + if(total_inputs == total_high_inputs, do: 0, else: 1),
                          queue: :queue.in({destination, source}, queue)
                      }
                  end

                :terminal ->
                  %{acc | queue: queue}
              end

            {:cont, acc}

          {:empty, _} ->
            {:halt, acc}
        end
      end
    )
  end

  def parse(input) do
    circuit =
      input
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn row, acc ->
        [source, destination] = String.split(row, " -> ")

        destination = String.split(destination, ", ")

        if String.starts_with?(source, "%") or String.starts_with?(source, "&") do
          start_symbol = String.at(source, 0)
          source = String.slice(source, 1..-1)

          Map.put(acc, source, %{
            kind: if(start_symbol == "%", do: :flip_flop, else: :conjunction),
            destination: destination,
            state: :off,
            parents: %{}
          })
        else
          Map.put(acc, source, %{kind: :broadcaster, destination: destination, parents: %{}})
        end
      end)

    Enum.reduce(
      circuit,
      circuit,
      fn {source, values}, acc ->
        for destination <- values.destination, reduce: acc do
          acc ->
            acc =
              if acc[destination] do
                acc
              else
                Map.put(acc, destination, %{kind: :terminal, parents: %{}})
              end

            put_in(acc, [destination, :parents, source], nil)
        end
      end
    )
  end

  def lcm(x, y) when is_integer(y) do
    div(x * y, Integer.gcd(x, y))
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
