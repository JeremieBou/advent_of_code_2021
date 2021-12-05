test_depths = [
  199,
  200,
  208,
  210,
  200,
  207,
  240,
  269,
  260,
  263
]

defmodule CountDepthRising do
  def count_depth_rising(depths) do
    count_depth_rising(depths, 0)
  end

  def count_depth_rising([previous | depths], count) do
    if length(depths) > 0 && List.first(depths) > previous do
      count_depth_rising(depths, count + 1)
    else
      count_depth_rising(depths, count)
    end
  end

  def count_depth_rising([], count) do
    count
  end
end

defmodule CountDepthRising2 do
  def count_depth_rising(depths) do
    count_depth_rising(depths, 0)
  end

  def count_depth_rising([a, b, c, d | depths], count) do
    if b + c + d > a + b + c do
      count_depth_rising([b, c, d] ++ depths, count + 1)
    else
      count_depth_rising([b, c, d] ++ depths, count)
    end
  end

  def count_depth_rising([_, _, _], count) do
    count
  end
end

{:ok, file} = File.read("day1_dataset.txt")
depth_strings = String.split(file, "\n")
depths = Enum.map(depth_strings, fn x -> elem(Integer.parse(x), 0) end)

IO.puts(CountDepthRising.count_depth_rising(test_depths))
IO.puts(CountDepthRising2.count_depth_rising(test_depths))

IO.puts(CountDepthRising.count_depth_rising(depths))
IO.puts(CountDepthRising2.count_depth_rising(depths))
