defmodule DetectBigHyrothermalVents do
  def point1(line) do
    Enum.at(line, 0)
  end

  def point2(line) do
    Enum.at(line, 1)
  end

  def x(line) do
    Enum.at(line, 0)
  end

  def y(line) do
    Enum.at(line, 1)
  end

  def generate_points_for_line(line, generate_diagonals) do
    cond do
      x(point1(line)) === x(point2(line)) ->
        Enum.to_list(y(point1(line))..y(point2(line)))
        |> Enum.map(fn y ->
          [x(point1(line)), y]
        end)

      y(point1(line)) === y(point2(line)) ->
        Enum.to_list(x(point1(line))..x(point2(line)))
        |> Enum.map(fn x ->
          [x, y(point1(line))]
        end)

      generate_diagonals ->
        Enum.to_list(y(point1(line))..y(point2(line)))
        |> Enum.with_index()
        |> Enum.map(fn {y, index} ->
          if x(point1(line)) < x(point2(line)) do
            [x(point1(line)) + index, y]
          else
            [x(point1(line)) - index, y]
          end
        end)

      true ->
        []
    end
  end

  def detect_big_hydrothermal_vents(submarine_vent_input, consider_diagonals) do
    {:ok, file} = File.read(submarine_vent_input)

    file
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" -> ")
      |> Enum.map(fn coordinate ->
        coordinate
        |> String.split(",")
        |> Enum.map(fn coordinate_part ->
          coordinate_part
          |> Integer.parse()
          |> elem(0)
        end)
      end)
    end)
    |> Enum.flat_map(fn line ->
      generate_points_for_line(line, consider_diagonals)
    end)
    |> Enum.group_by(fn point ->
      point
    end)
    |> Enum.count(fn {_key, value} -> length(value) >= 2 end)
  end
end

IO.inspect(DetectBigHyrothermalVents.detect_big_hydrothermal_vents("day5_test_input.txt", false))
IO.inspect(DetectBigHyrothermalVents.detect_big_hydrothermal_vents("day5_input.txt", false))

IO.inspect(DetectBigHyrothermalVents.detect_big_hydrothermal_vents("day5_test_input.txt", true))
IO.inspect(DetectBigHyrothermalVents.detect_big_hydrothermal_vents("day5_input.txt", true))
