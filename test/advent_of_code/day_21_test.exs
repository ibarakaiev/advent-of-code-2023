defmodule AdventOfCode.Day21Test do
  @moduledoc false
  use ExUnit.Case

  doctest AdventOfCode.Day21

  @input """
  ...........
  .....###.#.
  .###.##..#.
  ..#.#...#..
  ....#.#....
  .##..S####.
  .##..#...#.
  .......##..
  .##.#.####.
  .##..##.##.
  ...........
  """

  test "part 1" do
    assert AdventOfCode.Day21.solve(@input, 6, part: 1) == 16
  end

  test "part 2 (6 steps)" do
    assert AdventOfCode.Day21.solve(@input, 6, part: 2) == 16
  end

  # test "part 2 (10 steps)" do
  #   assert AdventOfCode.Day21.solve(@input, 10, part: 2) == 1594
  # end

  # test "part 2 (50 steps)" do
  #   assert AdventOfCode.Day21.solve(@input, 50, part: 2) == 6536
  # end

  # test "part 2 (100 steps)" do
  #   assert AdventOfCode.Day21.solve(@input, 100, part: 2) == 167_004
  # end
end
