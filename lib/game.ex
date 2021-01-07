defmodule Game do
  def new(%{width: width, height: height, mines: mines}) do
    :random.seed(:erlang.now)
    indices = get_indices(width, height)
    mine_list = Enum.take_random(indices, mines)
    for index <- indices, into: %{} do
      {index, generate_field(index, mine_list)}
    end
  end

  def get_indices(width, height) do
    for x <- 1..width, y <- 1..height do {x, y} end
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

  def reveal(game, {x, y}) do
    case game[{x, y}].state do
      :hidden -> do_reveal(game, {x, y})
      _ -> game
    end
  end

  def do_reveal(game, {x, y}) do
    indices = get_reveal_fields(MapSet.new, game, {x, y}) |> List.flatten |> Enum.uniq
    updated_fields = for index <- indices, into: %{} do
      {index, %{game[index] | :state => :revealed}}
    end
    Map.merge(game, updated_fields)
  end

  def get_reveal_fields(ignore_neighbors, game, {x, y}) do
    cond do
      not Map.has_key?(game, {x, y}) -> []
      game[{x, y}].adjacent > 0 or game[{x, y}].mine -> [{x, y}]
      true -> [{x, y}] ++ Enum.map(
        Enum.filter(
          get_neighbors({x, y}),
          fn({x, y}) -> {x, y} not in ignore_neighbors end
        ),
        &get_reveal_fields(
          ignore_neighbors |> MapSet.union(get_neighbors({x, y}) |> MapSet.new),
          game,
          &1
        )
      )
    end
  end

  def flag(game, {x, y}) do
    case game[{x, y}].state do
      :revealed -> game
      :hidden -> %{game | {x, y} => %{game[{x, y}] | :state => :flagged}}
      :flagged -> %{game | {x, y} => %{game[{x, y}] | :state => :hidden}}
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
