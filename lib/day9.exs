defmodule LavaRisk do
  @directions [
    {0, 1},
    {0, -1},
    {1, 0},
    {-1, 0}
  ]

  def load_heightmap(heightmap_filename) do
    {:ok, heightmap_file} = File.read(heightmap_filename)

    heightmap_file
    |> String.split("\n")
    |> Enum.map(fn heightmap_file_line ->
      heightmap_file_line
      |> String.graphemes()
      |> Enum.map(fn heightmap_file_point ->
        heightmap_file_point
        |> Integer.parse()
        |> elem(0)
      end)
    end)
  end

  def point_on_map?({row, col}, heightmap) do
    row >= 0 and row < heightmap |> length and
      col >= 0 and col < heightmap |> Enum.at(0) |> length
  end

  def get_point({row, col}, heightmap) do
    heightmap
    |> Enum.at(row)
    |> Enum.at(col)
  end

  def get_adjacent_points({row, col}, heightmap) do
    @directions
    |> Enum.map(fn {t_row, t_col} ->
      {row + t_row, col + t_col}
    end)
    |> Enum.filter(fn point ->
      point
      |> point_on_map?(heightmap)
    end)
  end

  def get_adjacent_basin_points(point_coordinate, heightmap) do
    adjacent_points =
      point_coordinate
      |> get_adjacent_points(heightmap)

    adjacent_points
    |> Enum.filter(fn a_point_coordinate ->
      a_point_coordinate
      |> get_point(heightmap)
      |> Kernel.<(9)
    end)
  end

  def get_adjacent_basin_points(point, heightmap, visited_points) do
    get_adjacent_basin_points(point, heightmap) -- visited_points
  end

  def low_point?(point_coordinate, heightmap) do
    point =
      point_coordinate
      |> get_point(heightmap)

    get_adjacent_points(point_coordinate, heightmap)
    |> Enum.map(fn point_coordinate ->
      point_coordinate
      |> get_point(heightmap)
    end)
    |> Enum.all?(fn other_point ->
      other_point > point
    end)
  end

  def get_low_points(heightmap) do
    heightmap
    |> Enum.with_index()
    |> Enum.flat_map(fn {heightmap_line, row} ->
      heightmap_line
      |> Enum.with_index()
      |> Enum.map(fn g -> g end)
      |> Enum.map(fn {_heightmap_point, col} ->
        {row, col}
      end)
    end)
    |> Enum.filter(fn point_coordinate ->
      point_coordinate
      |> low_point?(heightmap)
    end)
  end

  def get_basin(point_coordinate, heightmap) do
    new_points = get_adjacent_basin_points(point_coordinate, heightmap)

    get_basin(new_points, heightmap, [])
  end

  def get_basin([point_coordinate | stack], heightmap, visited_points) do
    new_points = get_adjacent_basin_points(point_coordinate, heightmap, visited_points)

    get_basin(
      new_points ++ stack,
      heightmap,
      visited_points ++ [point_coordinate]
    )
  end

  def get_basin([], _heightmap, visited_points) do
    visited_points
    |> Enum.uniq()
  end

  def calculate_lava_risk(heightmap_filename) do
    heightmap = load_heightmap(heightmap_filename)

    heightmap
    |> get_low_points()
    |> Enum.map(fn point_coordinate ->
      point_coordinate
      |> get_point(heightmap)
      |> Kernel.+(1)
    end)
    |> Enum.sum()
  end

  def calculate_basins_product(heightmap_filename) do
    heightmap = load_heightmap(heightmap_filename)

    heightmap
    |> get_low_points()
    |> Enum.map(fn point_coordinate ->
      point_coordinate
      |> get_basin(heightmap)
      |> length()
    end)
    |> Enum.sort()
    |> Enum.take(-3)
    |> Enum.product()
  end
end

IO.inspect(LavaRisk.calculate_lava_risk("day9_test_input.txt"))
IO.inspect(LavaRisk.calculate_lava_risk("day9_input.txt"))

IO.inspect(LavaRisk.calculate_basins_product("day9_test_input.txt"))
IO.inspect(LavaRisk.calculate_basins_product("day9_input.txt"))
