defmodule AdventOfCode.Day13Test do
  use ExUnit.Case

  doctest AdventOfCode.Day13

  @input """
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """

  test "part 1" do
    assert AdventOfCode.Day13.solve(@input, part: 1) == 405
  end
end
