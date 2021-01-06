defmodule Game do
  def new(%{width: width, height: height, mines: mines}) do
    :random.seed(:erlang.now)
    indices = for x <- 1..width, y <- 1..height do {x, y} end
    mine_list = Enum.take_random(indices, mines)
    for index <- indices, into: %{} do
      {index, generate_field(index, mine_list)}
    end
  end

  defp generate_field({x, y}, mine_list) do
    mine = {x, y} in mine_list
    adjacent = get_neighbors({x, y})
    |> MapSet.new
    |> MapSet.intersection(MapSet.new(mine_list))
    |> MapSet.size
    %{
      state: :hidden,
      mine: mine,
      adjacent: adjacent
    }
  end

  defp generate_neighbor({x_delta, y_delta}, {x, y}) do
    {x + x_delta, y + y_delta}
  end

  defp get_neighbors({x, y}) do
    for x_delta <- -1..1, y_delta <- -1..1 do {x_delta, y_delta} end
    |> Enum.filter(fn(el) -> el != {0, 0} end)
    |> Enum.map(&generate_neighbor(&1, {x, y}))
  end

  def is_adjacent?({x1, y1}, {x2, y2}) do
    {x2, y2} in get_neighbors({x1, y1})
  end

  def reveal(game, {x, y}) do
    new_game = %{game | {x, y} => %{game[{x, y}] | :state => :revealed}}

    neighbors = get_neighbors({x, y})
    |> Enum.filter(fn({x, y}) -> game[{x, y}].adjacent == 0 end)

  end

  def do_reveal(game, {x, y}) do
    is_zero = if game[{x, y}] do
      game[{x, y}].adjacent == 0
    else
      false
    end
    case is_zero do
      false -> [{x, y}]
      true -> Enum.map(get_neighbors({x, y}), &do_reveal(game, &1))
    end
  end

  def game_check(game) do
    {revealed, hidden} = Enum.split_with(
      game,
      fn({_index, field}) -> field.state == :revealed end
    )
    cond do
      Enum.any?(revealed, fn({_index, field}) -> field.mine end) -> :lose
      Enum.all?(hidden, fn({_index, field}) -> field.mine end) -> :win
      true -> :continue
    end
  end

end
