defmodule AdventOfCode.Day19 do
  @moduledoc false
  def solve(input, part: 1) do
    {workflows, ratings} = parse(input)

    ratings
    |> Stream.map(fn rating ->
      result =
        1
        |> Stream.iterate(&(&1 + 1))
        |> Enum.reduce_while("in", fn _, workflow_name ->
          new_target =
            Enum.reduce_while(workflows[workflow_name], nil, fn condition, _acc ->
              case condition do
                {{feature, comparator, number}, target} ->
                  case comparator do
                    ">" -> if rating[feature] > number, do: {:halt, target}, else: {:cont, nil}
                    "<" -> if rating[feature] < number, do: {:halt, target}, else: {:cont, nil}
                  end

                {target} ->
                  {:halt, target}
              end
            end)

          case new_target do
            "A" -> {:halt, "A"}
            "R" -> {:halt, "R"}
            target -> {:cont, target}
          end
        end)

      {rating, result}
    end)
    |> Stream.reject(fn {_k, v} -> v == "R" end)
    |> Stream.map(fn {rating, _} ->
      rating |> Stream.map(fn {_k, v} -> v end) |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def solve(input, part: 2) do
    {workflows, _ratings} = parse(input)

    total_combinations(workflows, "in", %{"x" => {1, 4000}, "m" => {1, 4000}, "a" => {1, 4000}, "s" => {1, 4000}}, 0)
  end

  def total_combinations(workflows, node, ranges, step) do
    if step < length(workflows[node]) do
      case Enum.at(workflows[node], step) do
        {condition, target} ->
          total_combinations(workflows, node, adjust_ranges(ranges, condition, true), step + 1) +
            case target do
              "A" ->
                ranges = adjust_ranges(ranges, condition)

                for feature <- ["x", "m", "a", "s"], reduce: 1 do
                  acc ->
                    acc * max(0, elem(ranges[feature], 1) - elem(ranges[feature], 0) + 1)
                end

              "R" ->
                0

              target ->
                total_combinations(workflows, target, adjust_ranges(ranges, condition), 0)
            end

        {target} ->
          case target do
            "A" ->
              for feature <- ["x", "m", "a", "s"], reduce: 1 do
                acc ->
                  acc * (elem(ranges[feature], 1) - elem(ranges[feature], 0) + 1)
              end

            "R" ->
              0

            target ->
              total_combinations(workflows, target, ranges, 0)
          end
      end
    else
      0
    end
  end

  def adjust_ranges(ranges, {feature, comparator, number}, reverse? \\ false) do
    {old_min, old_max} = ranges[feature]

    if reverse? do
      if comparator == "<" do
        Map.put(ranges, feature, {max(old_min, number), old_max})
      else
        Map.put(ranges, feature, {old_min, min(old_max, number)})
      end
    else
      if comparator == "<" do
        Map.put(ranges, feature, {old_min, min(old_max, number - 1)})
      else
        Map.put(ranges, feature, {max(old_min, number + 1), old_max})
      end
    end
  end

  defp parse(input) do
    [workflows, ratings] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&String.split(&1, "\n", trim: true))

    workflows =
      workflows
      |> Enum.map(fn workflow ->
        [name, rules] = String.split(workflow, "{", trim: true)

        rules = rules |> String.slice(0..-2) |> String.split(",")

        all_but_last_rules =
          rules
          |> Enum.slice(0..-2)
          |> Enum.reduce([], fn rule, acc ->
            [condition, target] = String.split(rule, ":")

            feature = String.at(condition, 0)
            comparator = String.at(condition, 1)
            number = String.to_integer(String.slice(condition, 2..-1))
            [{{feature, comparator, number}, target} | acc]
          end)
          |> Enum.reverse()

        last_rule = List.last(rules)

        {name, all_but_last_rules ++ [{last_rule}]}
      end)
      |> Map.new()

    ratings =
      Enum.map(ratings, fn rating ->
        rating
        |> String.slice(1..-2)
        |> String.split(",")
        |> Enum.reduce(%{}, fn quantity, acc ->
          [feature, value] = String.split(quantity, "=")

          Map.put(acc, feature, String.to_integer(value))
        end)
      end)

    {workflows, ratings}
  end
end
