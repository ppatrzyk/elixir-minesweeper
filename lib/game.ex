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
    cond do
      {x, y} not in Map.keys(game) -> game
      game[{x, y}].state == :hidden -> do_reveal(game, {x, y})
      true -> game
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
    remaining_flags = get_remaining_flags(game)
    cond do
      {x, y} not in Map.keys(game) -> game
      remaining_flags <= 0 and game[{x, y}].state != :flagged -> game
      game[{x, y}].state == :revealed -> game
      game[{x, y}].state == :hidden -> %{game | {x, y} => %{game[{x, y}] | :state => :flagged}}
      game[{x, y}].state == :flagged -> %{game | {x, y} => %{game[{x, y}] | :state => :hidden}}
    end
  end

  def get_remaining_flags(game) do
    mines = Enum.filter(game, fn({{_x, _y}, field}) -> field.mine end) |> length
    flagged = Enum.filter(game, fn({{_x, _y}, field}) -> field.state == :flagged end) |> length
    mines - flagged
  end

  def game_check(game) do
    {revealed, hidden} = Enum.split_with(
      game,
      fn({_index, field}) -> field.state == :revealed end
    )
    remaining_flags = get_remaining_flags(game)
    cond do
      Enum.any?(revealed, fn({_index, field}) -> field.mine end) -> {:lose, ""}
      Enum.all?(hidden, fn({_index, field}) -> field.mine end) -> {:win, ""}
      true -> {:continue, Integer.to_string(remaining_flags)}
    end
  end

  def get_field_translate({x, y}, field_size) do
    {(x-1)*field_size, (y-1)*field_size}
  end

  def coord_to_index({coord_x, coord_y}, grid_offset, field_size) do
    {coord_x, coord_y} = {coord_x - grid_offset, coord_y - grid_offset}
    {1 + floor(coord_x / field_size), 1 + floor(coord_y / field_size)}
  end

end
