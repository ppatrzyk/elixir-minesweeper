defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

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

  @grid Game.get_indices(@grid_width, @grid_height)
  |> Enum.map(
    fn({x, y}) ->
      rect_spec(
        {@field_size, @field_size},
        stroke: {1, :white},
        translate: Game.get_field_translate({x, y}, @field_size),
        id: {x, y}
      )
    end
  )

  @graph Graph.build(font: :roboto, font_size: @text_size)
  |> add_specs_to_graph([
    rect_spec({@window_width, @window_height}),
    text_spec(@note, translate: {400, 300}),
    text_spec("Event received:", translate: {400, 350}, id: :testid),
    group_spec(@grid, translate: {@grid_offset, @grid_offset})
  ])

  def init(_, _opts) do
    {:ok, @graph, push: @graph}
  end

  def handle_input({:cursor_button, {:right, :release, _, {coord_x, coord_y}}}, _, state) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    Logger.info("right click captured (#{x}, #{y})")
    {:noreply, state}
  end

  def handle_input({:cursor_button, {:left, :release, _, {coord_x, coord_y}}}, _, state) do
    {x, y} = Game.coord_to_index({coord_x, coord_y}, @grid_offset, @field_size)
    Logger.info("left click captured (#{x}, #{y})")
    Logger.info("#{inspect(state)}")
    state = state |> Graph.modify(:testid, &text(&1, "new text"))
    {:noreply, state, push: state}
  end

  def handle_input(_, _, state) do
    {:noreply, state}
  end

  # graph = Graph.modify(graph, :event, &text(&1, @event_str <> inspect(event)))

end
