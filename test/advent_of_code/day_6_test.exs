defmodule AdventOfCode.Day6Test do
  use ExUnit.Case

  doctest AdventOfCode.Day6

  @input """
  Time:      7  15   30
  Distance:  9  40  200
  """

  test "part 1" do
    assert AdventOfCode.Day6.solve(@input, part: 1) == 288
  end

  test "part 2" do
    assert AdventOfCode.Day6.solve(@input, part: 2) == 71_503
  end
end
