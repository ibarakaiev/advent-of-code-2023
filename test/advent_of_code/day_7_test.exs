defmodule AdventOfCode.Day7Test do
  use ExUnit.Case

  doctest AdventOfCode.Day7

  @input """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  test "part 1" do
    assert AdventOfCode.Day7.solve(@input, part: 1) == 6440
  end
end
