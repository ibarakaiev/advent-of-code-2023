defmodule Benchmark do
  @moduledoc """
  https://stackoverflow.com/a/29674651

  Usage: Benchmark.measure(fn -> 123456 * 654321 end)
  """
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end
