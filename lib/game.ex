defmodule Game do
  def new(%{width: width, height: height, mines: mines}) do
    :random.seed(:erlang.now)
    indices = for x <- 1..width, y <- 1..height do
      {x, y}
    end
    mine_list = Enum.take_random(indices, mines)
    grid = Enum.map(
      indices,
      &generate_field(&1, mine_list)
    )
    grid
  end

  defp generate_field({x, y}, mine_list) do
    mine = {x, y} in mine_list
    %{mine: mine, state: :hidden}
  end
end
