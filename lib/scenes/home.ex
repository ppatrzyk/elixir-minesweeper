defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

  # todo add game to current state ?

  @note "Init example scenic"
  @text_size 24
  @test_str "lala "

  @window_width 1024
  @window_height 720
  @field_size 30
  @grid_offset 50
  @grid_width 9
  @grid_height 9
  @mines 10

  def init(_, _opts) do
    game = Game.new(%{width: @grid_width, height: @grid_height, mines: @mines})
    Logger.info(inspect(game))
    graph = make_grid(game)
    {:ok, {game, graph}, push: graph}
  end

  def make_grid(game) do
    grid = Enum.map(
      game,
      fn({{x, y}, field}) ->
        fill = case field.state do
          :hidden -> :white
          :flagged -> :red
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

    Graph.build(font: :roboto, font_size: @text_size)
    |> add_specs_to_graph([
      rect_spec({@window_width, @window_height}),
      text_spec(@note, translate: {400, 300}),
      text_spec("Event received:", translate: {400, 350}, id: :testid),
      group_spec(grid, translate: {@grid_offset, @grid_offset}),
      group_spec(annotations, translate: {@grid_offset, @grid_offset})
    ])
  end

  def handle_input({:cursor_button, {:right, :release, _, {coord_x, coord_y}}}, _, {game, _graph}) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    game = Game.flag(game, {x, y})
    Logger.info(Game.game_check(game))
    graph = make_grid(game)
    {:noreply, {game, graph}}
  end

  def handle_input({:cursor_button, {:left, :release, _, {coord_x, coord_y}}}, _, {game, _graph}) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    game = Game.reveal(game, {x, y})
    Logger.info(Game.game_check(game))
    # Logger.info("#{inspect(game)}")
    # graph = Graph.modify(graph, {x, y}, &rect(&1, {30, 30}, fill: :white, stroke: {1, :white}))
    graph = make_grid(game)
    {:noreply, {game, graph}, push: graph}
  end

  def handle_input(_, _, {game, graph}) do
    {:noreply, {game, graph}}
  end

  # graph = Graph.modify(graph, :event, &text(&1, @event_str <> inspect(event)))

end
