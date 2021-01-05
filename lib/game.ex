defmodule Game do
  def new(%{width: width, height: height, mines: mines}) do
    :random.seed(:erlang.now)
    indices = for x <- 1..width, y <- 1..height do
      {x, y}
    end
    # TODO implement
    IO.puts(inspect(indices))
    [1, 2, 3]
  end
end
