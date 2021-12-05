# forward X increases the horizontal position by X units.
# down X increases the depth by X units.
# up X decreases the depth by X units.

test_directions = [
  "forward 5",
  "down 5",
  "forward 8",
  "up 3",
  "down 8",
  "forward 2"
]

start = 0

defmodule CalculateDestination do
  def calculate_destination(directions) do
    calculate_destination(directions, 0, 0)
  end

  def calculate_destination([head | tail], current_depth, current_position) do
    [direction, quantity_string] = String.split(head, " ")
    quantity = elem(Integer.parse(quantity_string), 0)

    case direction do
      "forward" ->
        # IO.puts "forward"
        calculate_destination(tail, current_depth, current_position + quantity)

      "down" ->
        # IO.puts "down"
        calculate_destination(tail, current_depth + quantity, current_position)

      "up" ->
        # IO.puts "up"
        calculate_destination(tail, current_depth - quantity, current_position)
    end
  end

  def calculate_destination([], current_depth, current_position) do
    IO.puts(
      "depth #{current_depth}, position #{current_position}, total #{current_depth * current_position}"
    )
  end
end

defmodule CalculateDestination2 do
  def calculate_destination(directions) do
    calculate_destination(directions, 0, 0, 0)
  end

  def calculate_destination([head | tail], current_depth, current_position, aim) do
    [direction, quantity_string] = String.split(head, " ")
    quantity = elem(Integer.parse(quantity_string), 0)

    case direction do
      "forward" ->
        # IO.puts "forward"
        calculate_destination(
          tail,
          current_depth + aim * quantity,
          current_position + quantity,
          aim
        )

      "down" ->
        # IO.puts "down"
        calculate_destination(tail, current_depth, current_position, aim + quantity)

      "up" ->
        # IO.puts "up"
        calculate_destination(tail, current_depth, current_position, aim - quantity)
    end
  end

  def calculate_destination([], current_depth, current_position, aim) do
    IO.puts(
      "depth #{current_depth}, position #{current_position}, aim #{aim}, total #{current_depth * current_position}"
    )
  end
end

{:ok, file} = File.read("day2_input.txt")
directions = String.split(file, "\n")

CalculateDestination.calculate_destination(test_directions)
CalculateDestination.calculate_destination(directions)

CalculateDestination2.calculate_destination(test_directions)
CalculateDestination2.calculate_destination(directions)
