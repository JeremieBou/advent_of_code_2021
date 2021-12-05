defmodule PlayBingo do
  def prepare_cards(card_strings) do
    card_strings
    |> Enum.map(fn card ->
        String.split(card, "\n")
        |> Enum.map(fn row ->
          String.trim(row)
          |> String.split(" ")
          |> Enum.filter(fn x -> x != "" end)
          |> Enum.map(fn cell ->
            cell
            |> Integer.parse()
            |> elem(0)
          end)

        end)
      end)
  end

  def prepare_numbers(number_strings) do
    number_strings
      |> String.split(",")
      |> Enum.map(fn number_string ->
        number_string
        |> Integer.parse()
        |> elem(0)
      end)
  end

  def map_card_cells(card, map_fn) do
    card
    |> Enum.map(fn row ->
      row
      |> Enum.map(fn cell ->
        map_fn.(cell)
      end)
    end)
  end

  def play_number(cards, number) do
    cards
    |> Enum.map(fn card ->
      map_card_cells(card, fn cell ->
        if cell === number do
          -1
        else
          cell
        end
      end)
    end)
  end

  def winner?(card) do
    num_columns = length(Enum.at(card, 0))

    card
      |> Enum.any?(fn row ->
        row
        |> Enum.all?(fn cell ->
          cell === -1
        end)
      end) or Enum.to_list(0..num_columns)
      |> Enum.any?(fn column_index ->
        card
          |> Enum.all?(fn row ->
            Enum.at(row, column_index) == -1
          end)
      end)
  end

  def score_card(card, last_number) do
    card
    |> List.flatten()
    |> Enum.reject(fn cell ->
      cell === -1
    end)
    |> Enum.sum()
    |> Kernel.*(last_number)
  end

  def play_game([next_number | numbers], cards) do
    played_cards = play_number(cards, next_number)

    winning_card = played_cards
      |> Enum.find(fn card ->
        winner?(card)
      end)

    if winning_card === :nil do
      play_game(numbers, played_cards)
    else
      score_card(winning_card, next_number)
    end
  end

  def play_loosing_game([next_number | numbers], cards) do
    played_cards = play_number(cards, next_number)

    remaining_cards = Enum.filter(played_cards, fn card ->
      !winner?(card)
    end)

    if length(remaining_cards) === 0 do
      score_card(Enum.at(played_cards, 0), next_number)
    else
      play_loosing_game(numbers, remaining_cards)
    end
  end


  def play_bingo(filename) do
    {:ok, file} = File.read(filename)
    [number_strings | card_strings] = String.split(file, "\n\n")

    numbers = prepare_numbers(number_strings)
    cards = prepare_cards(card_strings)

    winning_score = play_game(numbers, cards)
    loosing_score = play_loosing_game(numbers, cards)

    IO.puts(winning_score)
    IO.puts(loosing_score)
  end
end

PlayBingo.play_bingo("day4_test_input.txt")
PlayBingo.play_bingo("day4_input.txt")
