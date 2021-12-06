defmodule LanternFishGrowth do
  def calculate_lantern_fish(lantern_fish, days) when days === 0 do
    lantern_fish
    |> Enum.map(fn {_fish_timer, count} ->
      count
    end)
    |> Enum.sum()
  end

  def calculate_lantern_fish(lantern_fish, days) do
    new_fish = Map.get(lantern_fish, 0)

    next_fish1 =
      lantern_fish
      |> Enum.map(fn {fish_timer, count} ->
        if fish_timer === 0 do
          {6, count}
        else
          {fish_timer - 1, count}
        end
      end)
      |> Enum.group_by(fn {fish_timer, count} -> fish_timer end)
      |> Enum.map(fn {fish_timer, counts} ->
        count =
          counts
          |> Enum.map(fn c ->
            elem(c, 1)
          end)
          |> Enum.sum()

        {fish_timer, count}
      end)
      |> Kernel.++([{8, new_fish}])

    next_fish =
      next_fish1
      |> Enum.into(%{})

    calculate_lantern_fish(next_fish, days - 1)
  end

  def prepare_lantern_fish_input(filename) do
    base_timers =
      0..8
      |> Enum.map(fn num -> {num, 0} end)
      |> Enum.into(%{})

    {:ok, file} = File.read(filename)

    file
    |> String.split(",")
    |> Enum.map(fn fish_timer ->
      fish_timer
      |> Integer.parse()
      |> elem(0)
    end)
    |> Enum.reduce(base_timers, fn fish, timers ->
      timers
      |> Map.replace(fish, Map.get(timers, fish) + 1)
    end)
  end
end

test_input = LanternFishGrowth.prepare_lantern_fish_input("day6_test_input.txt")
IO.inspect(LanternFishGrowth.calculate_lantern_fish(test_input, 80))
IO.inspect(LanternFishGrowth.calculate_lantern_fish(test_input, 256))

input = LanternFishGrowth.prepare_lantern_fish_input("day6_input.txt")
IO.inspect(LanternFishGrowth.calculate_lantern_fish(input, 80))
IO.inspect(LanternFishGrowth.calculate_lantern_fish(input, 256))
