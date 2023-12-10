defmodule AdventOfCode.Day10Test do
  use ExUnit.Case

  doctest AdventOfCode.Day10

  test "part 1, example 1" do
    input = """
    -L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF
    """

    assert AdventOfCode.Day10.solve(input, part: 1) == 4
  end

  test "part 1, example 2" do
    input = """
    7-F7-
    .FJ|7
    SJLL7
    |F--J
    LJ.LJ
    """

    assert AdventOfCode.Day10.solve(input, part: 1) == 8
  end

  test "part 2, example 1" do
    input = """
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """

    assert AdventOfCode.Day10.solve(input, part: 2) == 4
  end

  test "part 2, example 2" do
    input = """
    ..........
    .S------7.
    .|F----7|.
    .||....||.
    .||....||.
    .|L-7F-J|.
    .|..||..|.
    .L--JL--J.
    ..........
    """

    assert AdventOfCode.Day10.solve(input, part: 2) == 4
  end

  test "part 2, example 3" do
    input = """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """

    assert AdventOfCode.Day10.solve(input, part: 2) == 8
  end

  test "part 2, example 4" do
    input = """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """

    assert AdventOfCode.Day10.solve(input, part: 2) == 10
  end
end
