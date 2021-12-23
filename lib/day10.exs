defmodule SyntaxChecker do
  @corruption_score %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  @correction_score %{
    ")" => 1,
    "]" => 2,
    "}" => 3,
    ">" => 4
  }

  @closing_braket %{
    "(" => ")",
    "[" => "]",
    "{" => "}",
    "<" => ">"
  }

  defp load_subsystem_code(subsytem_filename) do
    {:ok, subsystem_file} = File.read(subsytem_filename)

    subsystem_file
    |> String.split("\n")
    |> Enum.map(fn subsystem_line ->
      subsystem_line
      |> String.graphemes()
    end)
  end

  defp is_opening?(bracket) do
    bracket === "(" or bracket === "[" or bracket === "{" or bracket === "<"
  end

  defp open_matches_closing?(open, closing) do
    @closing_braket |> Map.get(open) === closing
  end

  defp get_corrupted_character(subsystem_line) do
    subsystem_line
    |> Enum.reduce({[], nil}, fn bracket, {stack, corrupted_bracket} ->
      cond do
        corrupted_bracket !== nil ->
          {stack, corrupted_bracket}

        is_opening?(bracket) ->
          {stack ++ [bracket], nil}

        true ->
          [maybe_opening_bracket | inverse_remaining_stack] = stack |> Enum.reverse()

          if open_matches_closing?(maybe_opening_bracket, bracket) do
            {inverse_remaining_stack |> Enum.reverse(), nil}
          else
            {inverse_remaining_stack |> Enum.reverse(), bracket}
          end
      end
    end)
    |> elem(1)
  end

  defp score_maybe_corrupted_line(subsystem_line) do
    corrupted_character = get_corrupted_character(subsystem_line)

    if corrupted_character === nil do
      0
    else
      @corruption_score
      |> Map.get(corrupted_character)
    end
  end

  defp filter_corrupted_lines(subsystem_code) do
    subsystem_code
    |> Enum.filter(fn subsystem_line ->
      get_corrupted_character(subsystem_line) === nil
    end)
  end

  defp get_completion_sequence(subsystem_line) do
    subsystem_line
    |> Enum.reduce([], fn bracket, stack ->
      if is_opening?(bracket) do
        stack ++ [bracket]
      else
        stack |> Enum.reverse() |> tl() |> Enum.reverse()
      end
    end)
    |> Enum.reverse()
    |> Enum.map(fn bracket ->
      @closing_braket
      |> Map.get(bracket)
    end)
  end

  defp score_line_completion(subsystem_line) do
    subsystem_line
    |> get_completion_sequence()
    |> Enum.reduce(0, fn bracket, score ->
      score * 5 +
        (@correction_score
         |> Map.get(bracket))
    end)
  end

  def calculate_syntax_corruption_score(subsytem_filename) do
    subsystem_code = load_subsystem_code(subsytem_filename)

    subsystem_code
    |> Enum.map(&score_maybe_corrupted_line/1)
    |> Enum.sum()
  end

  def calculate_syntax_completion_score(subsytem_filename) do
    subsystem_code = load_subsystem_code(subsytem_filename)

    scores =
      subsystem_code
      |> filter_corrupted_lines()
      |> Enum.map(&score_line_completion/1)
      |> Enum.sort()

    middle_index = scores |> length() |> div(2)

    scores |> Enum.at(middle_index)
  end
end

# IO.inspect(SyntaxChecker.calculate_syntax_corruption_score("day10_test_input.txt"))
# IO.inspect(SyntaxChecker.calculate_syntax_corruption_score("day10_input.txt"))

IO.inspect(SyntaxChecker.calculate_syntax_completion_score("day10_test_input.txt"))
IO.inspect(SyntaxChecker.calculate_syntax_completion_score("day10_input.txt"))
