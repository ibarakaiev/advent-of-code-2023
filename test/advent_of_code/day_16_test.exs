defmodule AdventOfCode.Day16Test do
  use ExUnit.Case

  doctest AdventOfCode.Day16

  test "part 1 (example)" do
    input = File.read!("test/advent_of_code/inputs/day_16_example.txt")
    assert AdventOfCode.Day16.solve(input, part: 1) == 46
  end

  # test "part 1 (real)" do
  #   input = File.read!("test/advent_of_code/inputs/day_16_input.txt")
  #   dbg(AdventOfCode.Day16.solve(input, part: 1))
  # end

  test "part 2 (example)" do
    input = File.read!("test/advent_of_code/inputs/day_16_example.txt")
    assert AdventOfCode.Day16.solve(input, part: 2) == 51
  end

  # test "part 2 (real)" do
  #   input = File.read!("test/advent_of_code/inputs/day_16_input.txt")
  #   dbg(AdventOfCode.Day16.solve(input, part: 2))
  # end
end
