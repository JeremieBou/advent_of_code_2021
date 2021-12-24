defmodule SimulateOctopus do
  @directions [
    {0, 1},
    {0, -1},
    {1, 0},
    {-1, 0},
    {1, 1},
    {-1, 1},
    {1, -1},
    {-1, -1}
  ]

  defp get_octopus(octopus_configuration, row_index, col_index) do
    octopus_configuration
    |> Enum.at(row_index)
    |> Enum.at(col_index)
  end

  defp load_octopus_configuration(starting_octopus_filename) do
    {:ok, starting_octopus_file} = File.read(starting_octopus_filename)

    starting_octopus_file
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn octopus_line ->
      octopus_line
      |> String.graphemes()
      |> Enum.map(fn octopus_string ->
        octopus_string
        |> Integer.parse()
        |> elem(0)
      end)
    end)
  end

  defp simulate_step_neightbours(new_energy_levels, octopus_configuration) do
    octopus_configuration
    |> Enum.with_index()
    |> Enum.map(fn {octopus_line, row_index} ->
      octopus_line
      |> Enum.with_index()
      |> Enum.map(fn {octopus, col_index} ->
        @directions
        |> Enum.map(fn {d_row_index, d_col_index} ->
          other_row_index = row_index + d_row_index
          other_col_index = col_index + d_col_index

          if other_row_index >= 0 and other_row_index < length(new_energy_levels) and
               other_col_index >= 0 and other_col_index < length(octopus_line) do
            other_octopus = new_energy_levels |> get_octopus(other_row_index, other_col_index)

            if other_octopus > 9 do
              1
            else
              0
            end
          else
            0
          end
        end)
        |> Enum.sum()
        |> Kernel.+(octopus + 1)
      end)
    end)
  end

  defp are_synced?(octopus_configuration) do
    octopus_configuration
    |> Enum.reduce(0, fn octopus_line, sum ->
      octopus_line
      |> Enum.sum()
      |> Kernel.+(sum)
    end) === 0
  end

  defp flash_neighbours(new_energy_levels, octopus_configuration) do
    neightbour_energy_levels = simulate_step_neightbours(new_energy_levels, octopus_configuration)

    if neightbour_energy_levels === new_energy_levels do
      neightbour_energy_levels
    else
      flash_neighbours(neightbour_energy_levels, octopus_configuration)
    end
  end

  defp simulate_step(octopus_configuration) do
    new_energy_levels =
      octopus_configuration
      |> Enum.map(fn octopus_line ->
        octopus_line
        |> Enum.map(fn octopus ->
          octopus + 1
        end)
      end)
      |> flash_neighbours(octopus_configuration)

    count_flashes =
      new_energy_levels
      |> Enum.reduce(0, fn octopus_line, acc ->
        octopus_line
        |> Enum.reduce(0, fn octopus, sub_acc ->
          if octopus > 9 do
            sub_acc + 1
          else
            sub_acc
          end
        end)
        |> Kernel.+(acc)
      end)

    new_octopus_configuration =
      new_energy_levels
      |> Enum.map(fn octopus_line ->
        octopus_line
        |> Enum.map(fn octopus ->
          if octopus > 9 do
            0
          else
            octopus
          end
        end)
      end)

    {new_octopus_configuration, count_flashes}
  end

  def simulate_octopus(starting_octopus_filename, steps_to_simulate) do
    starting_octopus_configuration = load_octopus_configuration(starting_octopus_filename)

    Enum.to_list(0..(steps_to_simulate - 1))
    |> Enum.reduce({starting_octopus_configuration, 0, nil}, fn step,
                                                                {octopus_configuration, acc_count,
                                                                 synced_step} ->
      {new_octopus_configuration, step_count} = simulate_step(octopus_configuration)

      new_flashed_count = if step < 100, do: acc_count + step_count, else: acc_count

      if synced_step === nil do
        if are_synced?(new_octopus_configuration) do
          {new_octopus_configuration, new_flashed_count, step + 1}
        else
          {new_octopus_configuration, new_flashed_count, nil}
        end
      else
        {new_octopus_configuration, new_flashed_count, synced_step}
      end
    end)
  end
end

IO.inspect(SimulateOctopus.simulate_octopus("day11_test_input.txt", 200))
IO.inspect(SimulateOctopus.simulate_octopus("day11_input.txt", 1000))
