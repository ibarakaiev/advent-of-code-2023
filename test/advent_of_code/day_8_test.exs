defmodule AdventOfCode.Day8Test do
  use ExUnit.Case

  doctest AdventOfCode.Day8

  test "part 1" do
    input = """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """

    assert AdventOfCode.Day8.solve(input, part: 1) == 6
  end

  test "part 2" do
    input = """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """

    assert AdventOfCode.Day8.solve(input, part: 2) == 6
  end
end
