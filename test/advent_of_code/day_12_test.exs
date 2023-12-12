defmodule AdventOfCode.Day12Test do
  use ExUnit.Case

  doctest AdventOfCode.Day12

  @input """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

  test "part 1" do
    assert AdventOfCode.Day12.solve(@input, part: 1) == 21
  end

  test "part 2" do
    assert AdventOfCode.Day12.solve(@input, part: 2) == 525_152
  end
end
