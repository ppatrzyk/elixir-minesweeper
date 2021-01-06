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

  def get_neighbors({x, y}) do
    for x_delta <- -1..1, y_delta <- -1..1 do {x_delta, y_delta} end
    |> Enum.filter(fn(el) -> el != {0, 0} end)
    |> Enum.map(&generate_neighbor(&1, {x, y}))
  end
end
