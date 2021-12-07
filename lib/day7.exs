defmodule AlignCrabs do
  def get_fuel_cost(crab_positions, target) do
    crab_positions
    |> Enum.map(fn crab_position ->
      abs(crab_position - target)
    end)
    |> Enum.sum()
  end

  def get_fuel_cost2(crab_positions, target) do
    crab_positions
    |> Enum.map(fn crab_position ->
      n = abs(crab_position - target)
      round(n * (n + 1) / 2)
    end)
    |> Enum.sum()
  end

  def prepare_input(filename) do
    {:ok, file} = File.read(filename)

    positions =
      file
      |> String.split(",")
      |> Enum.map(fn fish_timer ->
        fish_timer
        |> Integer.parse()
        |> elem(0)
      end)

    min_position = Enum.min(positions)
    max_position = Enum.max(positions)

    {positions, min_position, max_position}
  end

  def align_crabs(filename) do
    {positions, min_position, max_position} = prepare_input(filename)

    Enum.to_list(min_position..max_position)
    |> Enum.map(fn target ->
      get_fuel_cost(positions, target)
    end)
    |> Enum.min()
  end

  def align_crabs2(filename) do
    {positions, min_position, max_position} = prepare_input(filename)

    Enum.to_list(min_position..max_position)
    |> Enum.map(fn target ->
      get_fuel_cost2(positions, target)
    end)
    |> Enum.min()
  end
end

IO.inspect(AlignCrabs.align_crabs("day7_test_input.txt"))
IO.inspect(AlignCrabs.align_crabs2("day7_test_input.txt"))
IO.inspect(AlignCrabs.align_crabs("day7_input.txt"))
IO.inspect(AlignCrabs.align_crabs2("day7_input.txt"))
