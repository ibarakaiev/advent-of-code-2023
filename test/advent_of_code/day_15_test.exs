defmodule AdventOfCode.Day15Test do
  use ExUnit.Case

  doctest AdventOfCode.Day15

  @input """
  rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
  """

  test "part 1" do
    assert AdventOfCode.Day15.solve(@input, part: 1) == 1320
  end

  test "part 2" do
    assert AdventOfCode.Day15.solve(@input, part: 2) == 145
  end
end
