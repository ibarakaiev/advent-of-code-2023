defmodule AdventOfCode.Day9Test do
  use ExUnit.Case

  doctest AdventOfCode.Day9

  test "part 1" do
    input = """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """

    assert AdventOfCode.Day9.solve(input, part: 1) == 114
  end
end
