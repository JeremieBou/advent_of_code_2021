test_input = [
  "00100",
  "11110",
  "10110",
  "10111",
  "10101",
  "01111",
  "00111",
  "11100",
  "10000",
  "11001",
  "00010",
  "01010"
]

# 2 new numbers
# gamma rate
# epsilon rate

defmodule CalculatePowerConsumption do
  def get_max_digit(diagnostic_codes, position) do
    get_max_digit(diagnostic_codes, position, 0, 0)
  end

  def get_max_digit([head | tail], position, count_zero, count_one) do
    if String.at(head, position) === "1" do
      get_max_digit(tail, position, count_zero, count_one + 1)
    else
      get_max_digit(tail, position, count_zero + 1, count_one)
    end
  end

  def get_max_digit([], _position, count_zero, count_one) do
    if count_one >= count_zero do
      1
    else
      0
    end
  end

  def get_positions(diagnostic_codes) do
    Enum.to_list(0..(String.length(Enum.at(diagnostic_codes, 0)) - 1))
  end

  def get_oxigen_generator_rating(diagnostic_codes, position) do
    if length(diagnostic_codes) <= 1 do
      string_digits = Enum.slice(String.split(Enum.at(diagnostic_codes, 0), ""), 1..-2)

      digits = Enum.map(string_digits, fn x -> elem(Integer.parse(x), 0) end)
      digit_to_binary(digits)
    else
      max_digit = get_max_digit(diagnostic_codes, position)

      remaining_diagnostic_codes =
        Enum.filter(diagnostic_codes, fn code -> String.at(code, position) == "#{max_digit}" end)

      get_oxigen_generator_rating(remaining_diagnostic_codes, position + 1)
    end
  end

  def get_co2_scrubber_rating(diagnostic_codes, position) do
    if length(diagnostic_codes) <= 1 do
      string_digits = Enum.slice(String.split(Enum.at(diagnostic_codes, 0), ""), 1..-2)

      digits = Enum.map(string_digits, fn x -> elem(Integer.parse(x), 0) end)
      digit_to_binary(digits)
    else
      min_digit = 1 - get_max_digit(diagnostic_codes, position)

      remaining_diagnostic_codes =
        Enum.filter(diagnostic_codes, fn code -> String.at(code, position) == "#{min_digit}" end)

      get_co2_scrubber_rating(remaining_diagnostic_codes, position + 1)
    end
  end

  def calculate_life_support_raiting(diagnostic_codes) do
    oxigen_generator_rating = get_oxigen_generator_rating(diagnostic_codes, 0)
    co2_scrubber_rating = get_co2_scrubber_rating(diagnostic_codes, 0)

    IO.puts(
      "oxigen generator rating: #{oxigen_generator_rating}, co2 scrubber rating: #{co2_scrubber_rating}, life support rating: #{oxigen_generator_rating * co2_scrubber_rating}"
    )
  end

  def digit_to_binary(digits) do
    Enum.reduce(Enum.with_index(Enum.reverse(digits)), 0, fn {digit, index}, decimal_number ->
      decimal_number + (:math.pow(2, index) |> round) * digit
    end)
  end

  def calculate_power_consumption(diagnostic_codes) do
    positions = get_positions(diagnostic_codes)

    max_digits = Enum.map(positions, fn position -> get_max_digit(diagnostic_codes, position) end)

    # Enum.reduce(Enum.with_index(Enum.reverse(max_digits)), 0, fn {digit, index}, decimal_number -> decimal_number + (:math.pow(2, index) |> round) * digit   end)
    gamma_rate = digit_to_binary(max_digits)

    epsilon_rate =
      Enum.reduce(Enum.with_index(Enum.reverse(max_digits)), 0, fn {digit, index},
                                                                   decimal_number ->
        decimal_number + (:math.pow(2, index) |> round) * (1 - digit)
      end)

    IO.puts(
      "gamma rate #{gamma_rate}, epsilon rate #{epsilon_rate}, power consumption #{gamma_rate * epsilon_rate}"
    )
  end
end

{:ok, file} = File.read("day3_input.txt")
diagnostics = String.split(file, "\n")

IO.puts(CalculatePowerConsumption.calculate_power_consumption(test_input))
IO.puts(CalculatePowerConsumption.calculate_life_support_raiting(test_input))

IO.puts(CalculatePowerConsumption.calculate_power_consumption(diagnostics))
IO.puts(CalculatePowerConsumption.calculate_life_support_raiting(diagnostics))
