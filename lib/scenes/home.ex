defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

  @field_size 30
  @grid_offset 100
  @grid_width 9
  @grid_height 9
  @mines 10
  @text_size 24
  @window_width (@grid_width*@field_size + @grid_offset*2)
  @window_height (@grid_height*@field_size + @grid_offset*2)

  def init(_, _opts) do
    game = Game.new(%{width: @grid_width, height: @grid_height, mines: @mines})
    graph = make_grid(game)
    {:ok, {game, graph}, push: graph}
  end

  def make_grid(game) do
    grid = Enum.map(
      game,
      fn({{x, y}, field}) ->
        fill = case field.state do
          :hidden -> :white
          :flagged -> :gray
          :revealed -> {:white, 0}
        end
        rect_spec(
          {@field_size, @field_size},
          stroke: {1, :gray},
          translate: Game.get_field_translate({x, y}, @field_size),
          fill: fill,
          id: {x, y}
        )
      end
    )

    annotations = Enum.map(
      game,
      fn({{x, y}, field}) ->
        str = cond do
          field.mine -> "*"
          field.adjacent > 0 -> "#{field.adjacent}"
          true -> ""
        end
        {trans_x, trans_y} = Game.get_field_translate({x, y}, @field_size)
        {trans_x, trans_y} = {trans_x + @field_size*1/3, trans_y + @field_size*2/3}
        text_spec(str, translate: {trans_x, trans_y})
      end
    )

    {state, remaining_flags} = Game.game_check(game)
    Logger.info(Atom.to_string(state))
    message = case state do
      :continue -> "Play, remaining flags: " <> remaining_flags
      :win -> "You won!"
      :lose -> "You lost!"
    end

    Graph.build(font: :roboto, font_size: @text_size)
    |> add_specs_to_graph([
      rect_spec({@window_width, @window_height}),
      text_spec(message, translate: {10, 20}),
      button_spec("Restart", id: :restart, theme: :primary, translate: {10, 40}),
      group_spec(annotations, translate: {@grid_offset, @grid_offset}),
      group_spec(grid, translate: {@grid_offset, @grid_offset})
    ])
  end

  def handle_input({:cursor_button, {:right, :release, _, {coord_x, coord_y}}}, _, {game, _graph}) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    game = Game.flag(game, {x, y})
    graph = make_grid(game)
    {:noreply, {game, graph}, push: graph}
  end

  def handle_input({:cursor_button, {:left, :release, _, {coord_x, coord_y}}}, _, {game, _graph}) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    game = Game.reveal(game, {x, y})
    graph = make_grid(game)
    {:noreply, {game, graph}, push: graph}
  end

  def handle_input(_, _, {game, graph}) do
    {:noreply, {game, graph}}
  end

  def filter_event(_event, _, {_game, _graph}) do
    # this crashes scene (?)
    init(true, true)
  end

end
