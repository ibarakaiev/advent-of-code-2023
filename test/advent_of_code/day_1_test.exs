defmodule AdventOfCode.Day1Test do
  use ExUnit.Case

  doctest AdventOfCode.Day1

  test "part 1" do
    input = """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """

    assert AdventOfCode.Day1.solve(input, part: 1) == 142
  end

  test "part 2" do
    input = """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """

    assert AdventOfCode.Day1.solve(input, part: 2) == 281
  end
end
