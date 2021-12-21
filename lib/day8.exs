defmodule DecodeSignals do
  def decode_signal_pattern(pattern_string) do
    cond do
      ## 1
      String.length(pattern_string) == 2 ->
        1

      ## 7
      String.length(pattern_string) == 3 ->
        1

      ## 4
      String.length(pattern_string) == 4 ->
        1

      ## 8
      String.length(pattern_string) == 7 ->
        1

      true ->
        0
    end
  end

  def decode_signals(filename) do
    {:ok, file} = File.read(filename)

    file
    |> String.split("\n")
    |> Enum.flat_map(fn input_line ->
      input_line
      |> String.split("|")
      |> Enum.at(1)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(fn signal_pattern_string ->
        signal_pattern_string
        |> decode_signal_pattern()
      end)
    end)
    |> Enum.sum()
  end
end

defmodule DecodeSignals2 do
  @moduledoc """
     2
  3    0
     5
  4    1
     6
  """

  @digit_map [
    [0, 1, 2, 3, 4, 6],
    [0, 1],
    [0, 2, 4, 5, 6],
    [0, 1, 2, 5, 6],
    [0, 1, 3, 5],
    [1, 2, 3, 5, 6],
    [1, 2, 3, 4, 5, 6],
    [0, 1, 2],
    [0, 1, 2, 3, 4, 5, 6],
    [0, 1, 2, 3, 5, 6]
  ]

  @base_map [
    [[], [], [], [], [], nil, []],
    [[], [], nil, nil, nil, nil, nil],
    [[], nil, [], nil, [], [], []],
    [[], [], [], nil, nil, [], []],
    [[], [], nil, [], nil, [], nil],
    [nil, [], [], [], nil, [], []],
    [nil, [], [], [], [], [], []],
    [[], [], [], nil, nil, nil],
    [[], [], [], [], [], [], []],
    [[], [], [], [], nil, [], []]
  ]

  defp get_number_signals(signal, number) do
    signal
    |> Enum.filter(fn signal_code ->
      length(signal_code) === number
    end)
  end

  defp get_number_signal(signal, number) do
    signal
    |> get_number_signals(number)
    |> Enum.at(0)
  end

  defp replace_decoder_part(digit_decoder, position, new_digit_parts) do
    digit_decoder
    |> Enum.with_index()
    |> Enum.map(fn {digit_decoder_part, index} ->
      if index == position do
        new_digit_parts
      else
        digit_decoder_part
      end
    end)
  end

  defp replace_decoder_digit(decoder, position, new_digit_parts) do
    decoder
    |> Enum.with_index()
    |> Enum.map(fn {digit_decoder, index} ->
      if Enum.any?(Enum.at(@digit_map, index), fn digit_part_index ->
           digit_part_index === position
         end) do
        a =
          digit_decoder
          |> replace_decoder_part(position, new_digit_parts)

        a
      else
        digit_decoder
      end
    end)
  end

  defp remove_nils(decoder_digit) do
    decoder_digit
    |> Enum.filter(fn decoder_digit_part ->
      decoder_digit_part != nil
    end)
  end

  defp decoder_digit_comninations(decoder_digit) do
    decoder_digit_no_nil =
      decoder_digit
      |> remove_nils()

    decoder_digit_no_nil
    |> Enum.reduce([[]], fn decoder_digit_part, combinations ->
      decoder_digit_part
      |> Enum.flat_map(fn part_character ->
        combinations
        |> Enum.map(fn combination ->
          combination ++ [part_character]
        end)
      end)
    end)
    |> Enum.map(fn combination ->
      combination
      |> Enum.uniq()
    end)
    |> Enum.filter(fn combination ->
      length(combination) === length(decoder_digit_no_nil)
    end)
    |> Enum.map(fn combination ->
      combination
      |> Enum.sort()
      |> Enum.join()
    end)
  end

  defp decode_signal(decoder, signal) do
    signal_sorted =
      signal
      |> Enum.sort()

    # Get digit decoder that matches signal
    next_decoder_digit =
      decoder
      |> Enum.filter(fn decoder_digit ->
        combinations = decoder_digit_comninations(decoder_digit)
        signal_sorted_string = signal_sorted |> Enum.join("")

        combinations
        |> Enum.any?(fn combination ->
          combination === signal_sorted_string
        end)
      end)
      |> Enum.at(0)

    next_decoder_digit
    |> Enum.map(fn decoder_digit_part ->
      if decoder_digit_part === nil do
        nil
      else
        decoder_digit_part
        |> Enum.filter(fn part_character ->
          signal_sorted
          |> Enum.any?(fn signal_character ->
            signal_character === part_character
          end)
        end)
      end
    end)
    |> Enum.zip(next_decoder_digit)
    |> Enum.with_index()
    |> Enum.filter(fn {digit_combo, _index} ->
      digit_combo !== {nil, nil}
    end)
    |> Enum.filter(fn {{decoder_part_after, decoder_part_before}, _index} ->
      length(decoder_part_before) > length(decoder_part_after)
    end)
    |> Enum.reduce(decoder, fn {{decoder_part_after, decoder_part_before}, index}, acc_decoder ->
      {_other_decoder_part_after, other_index} =
        acc_decoder
        |> Enum.at(8)
        |> Enum.with_index()
        |> Enum.filter(fn {acc_decoder_part, index2} ->
          acc_decoder_part == decoder_part_before and index2 !== index
        end)
        |> Enum.at(0)

      acc_decoder
      |> replace_decoder_digit(index, decoder_part_after)
      |> replace_decoder_digit(other_index, decoder_part_before -- decoder_part_after)
    end)
  end

  defp decode_code_part(code_part, decoder) do
    code_part_string =
      code_part
      |> Enum.sort()
      |> Enum.join()

    decoder
    |> Map.get(code_part_string)
    |> Integer.to_string()
  end

  defp decode_input_line(input_line) do
    [signal, code] =
      String.split(input_line, "|")
      |> Enum.map(fn input_part ->
        input_part
        |> String.trim()
        |> String.split(" ")
        |> Enum.map(fn input_signal ->
          input_signal
          |> String.graphemes()
        end)
      end)

    one_signal = get_number_signal(signal, 2)
    four_signal = get_number_signal(signal, 4) -- one_signal
    seven_signal = get_number_signal(signal, 3) -- one_signal
    eight_signal = ((get_number_signal(signal, 7) -- one_signal) -- four_signal) -- seven_signal

    five_signals = get_number_signals(signal, 5)
    six_signals = get_number_signals(signal, 6)

    initial_decoder_map =
      @base_map
      |> replace_decoder_digit(0, one_signal)
      |> replace_decoder_digit(1, one_signal)
      |> replace_decoder_digit(2, seven_signal)
      |> replace_decoder_digit(3, four_signal)
      |> replace_decoder_digit(4, eight_signal)
      |> replace_decoder_digit(5, four_signal)
      |> replace_decoder_digit(6, eight_signal)

    decoder =
      (five_signals ++ six_signals)
      |> Enum.reduce(initial_decoder_map, fn next_signal, acc_decoder ->
        decode_signal(acc_decoder, next_signal)
      end)
      |> Enum.map(fn decoder_part ->
        decoder_part
        |> Enum.sort()
        |> Enum.join("")
      end)
      |> Enum.with_index()
      |> Map.new()

    code
    |> Enum.map(fn code_part ->
      code_part
      |> decode_code_part(decoder)
    end)
    |> Enum.join()
    |> Integer.parse()
    |> elem(0)
  end

  def decode_signals(filename) do
    {:ok, file} = File.read(filename)

    file
    |> String.split("\n")
    |> Enum.map(fn input_line ->
      decode_input_line(input_line)
    end)
    |> Enum.sum()
  end
end

# IO.inspect(DecodeSignals.decode_signals("day8_test_input.txt"))
# IO.inspect(DecodeSignals.decode_signals("day8_input.txt"))

IO.inspect(DecodeSignals2.decode_signals("day8_test_input.txt"))
IO.inspect(DecodeSignals2.decode_signals("day8_test_input2.txt"))
IO.inspect(DecodeSignals2.decode_signals("day8_input.txt"))
