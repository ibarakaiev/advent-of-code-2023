defmodule AdventOfCode.Day7 do
  @moduledoc false

  def solve(input, part: part) do
    card_strength = part |> card_order() |> Enum.with_index() |> Map.new()

    kind_strength =
      [:high_card, :one_pair, :two_pair, :three_of_a_kind, :full_house, :four_of_a_kind, :five_of_a_kind]
      |> Enum.with_index()
      |> Map.new()

    input
    |> String.trim()
    |> String.split()
    |> Stream.chunk_every(2)
    |> Stream.map(fn [hand, bid] ->
      bid = String.to_integer(bid)

      graphemes = String.graphemes(hand)

      frequencies =
        case part do
          1 ->
            Enum.frequencies(graphemes)

          2 ->
            frequencies = Enum.frequencies(graphemes)

            if Map.has_key?(frequencies, "J") and length(Map.keys(frequencies)) > 1 do
              highest_frequency_card =
                frequencies
                |> Enum.reject(fn {card, _frequency} -> card == "J" end)
                |> Enum.max_by(fn {_card, frequency} -> frequency end)
                |> elem(0)

              frequencies
              |> Map.put(highest_frequency_card, frequencies[highest_frequency_card] + frequencies["J"])
              |> Map.delete("J")
            else
              frequencies
            end
        end

      frequencies_list = frequencies |> Map.values() |> Enum.sort()

      kind =
        case frequencies_list do
          [1, 1, 1, 1, 1] ->
            :high_card

          [1, 1, 1, 2] ->
            :one_pair

          [1, 2, 2] ->
            :two_pair

          [1, 1, 3] ->
            :three_of_a_kind

          [2, 3] ->
            :full_house

          [1, 4] ->
            :four_of_a_kind

          [5] ->
            :five_of_a_kind
        end

      {
        hand,
        %{
          bid: bid,
          kind: kind
        }
      }
    end)
    |> Enum.to_list()
    # [
    #   {
    #     "32T3K",
    #     %{
    #       kind: :one_pair,
    #       bid: 765,
    #     }
    #   },
    #   ...
    # ]
    |> Enum.sort(fn left, right ->
      left_kind_strength = kind_strength[elem(left, 1)[:kind]]
      right_kind_strength = kind_strength[elem(right, 1)[:kind]]

      if left_kind_strength != right_kind_strength do
        left_kind_strength < right_kind_strength
      else
        left_hand = left |> elem(0) |> String.graphemes()
        right_hand = right |> elem(0) |> String.graphemes()

        Enum.reduce_while(0..4, nil, fn i, _acc ->
          left_card = Enum.at(left_hand, i)
          right_card = Enum.at(right_hand, i)

          if left_card == right_card do
            {:cont, nil}
          else
            {:halt, card_strength[left_card] <= card_strength[right_card]}
          end
        end)
      end
    end)
    |> Stream.map(&elem(&1, 1)[:bid])
    |> Stream.with_index(1)
    |> Stream.map(&(elem(&1, 0) * elem(&1, 1)))
    |> Enum.sum()
  end

  defp card_order(part) do
    case part do
      1 -> ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
      2 -> ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]
    end
  end
end
