defmodule AdventOfCode.Day18Test do
  use ExUnit.Case

  doctest AdventOfCode.Day18

  @input """
  R 6 (#70c710)
  D 5 (#0dc571)
  L 2 (#5713f0)
  D 2 (#d2c081)
  R 2 (#59c680)
  D 2 (#411b91)
  L 5 (#8ceee2)
  U 2 (#caa173)
  L 1 (#1b58a2)
  U 2 (#caa171)
  R 2 (#7807d2)
  U 3 (#a77fa3)
  L 2 (#015232)
  U 2 (#7a21e3)
  """

  test "part 1" do
    assert AdventOfCode.Day18.solve(@input, part: 1) == 62
  end

  test "part 2" do
    assert AdventOfCode.Day18.solve(@input, part: 2) == 952_408_144_115
  end
end
