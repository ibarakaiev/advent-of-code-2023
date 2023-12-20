defmodule AdventOfCode.Day20Test do
  @moduledoc false
  use ExUnit.Case

  doctest AdventOfCode.Day20

  test "part 1 (example 1)" do
    assert AdventOfCode.Day20.solve(
             """
             broadcaster -> a, b, c
             %a -> b
             %b -> c
             %c -> inv
             &inv -> a
             """,
             part: 1
           ) == 32_000_000
  end

  test "part 1 (example 2)" do
    assert AdventOfCode.Day20.solve(
             """
             broadcaster -> a
             %a -> inv, con
             &inv -> b
             %b -> con
             &con -> output
             """,
             part: 1
           ) == 11_687_500
  end
end
