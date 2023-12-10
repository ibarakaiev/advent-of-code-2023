defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  doctest AdventOfCode.Day10

  test "part 1, example 1" do
    input = """
    -L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF
    """

    assert AdventOfCode.Day10.solve(input, part: 1) == 4
  end

  test "part 1, example 2" do
    input = """
    7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ
    """

    assert AdventOfCode.Day10.solve(input, part: 1) == 8
  end
end
