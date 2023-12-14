defmodule AdventOfCode.Day14Test do
  use ExUnit.Case

  doctest AdventOfCode.Day14

  @input """
  O....#....
  O.OO#....#
  .....##...
  OO.#O....O
  .O.....O#.
  O.#..O.#.#
  ..O..#O..O
  .......O..
  #....###..
  #OO..#....
  """

  test "part 1" do
    assert AdventOfCode.Day14.solve(@input, part: 1) == 136
  end

  test "part 2" do
    assert AdventOfCode.Day14.solve(@input, part: 2) == 64
  end
end
