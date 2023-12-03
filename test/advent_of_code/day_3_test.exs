defmodule AdventOfCode.Day3Test do
  use ExUnit.Case

  doctest AdventOfCode.Day3

  @input """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  test "part 1" do
    assert AdventOfCode.Day3.solve(@input, part: 1) == 4361
  end

  test "part 2" do
    assert AdventOfCode.Day3.solve(@input, part: 2) == 467_835
  end
end
