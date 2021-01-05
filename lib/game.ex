defmodule Game do
  def new(%{width: width, height: height, mines: mines}) do
    :random.seed(:erlang.now)
    indices = for x <- 1..width, y <- 1..height do
      {x, y}
    end
    mine_list = Enum.take_random(indices, mines)
    grid = for index <- indices, into: %{} do
      {index, generate_field(index, mine_list)}
    end
    grid
  end

  defp generate_field({x, y}, mine_list) do
    mine = {x, y} in mine_list
    %{mine: mine, state: :hidden}
  end
end
