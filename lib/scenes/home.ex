defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  # import Scenic.Components

  @note "Init example scenic"
  @text_size 24

  @window_width 1024
  @window_height 720
  @field_size 30
  @grid_width 9
  @grid_height 9
  @mines 10

  @grid [
    rect_spec(
      {@field_size, @field_size},
      stroke: {1, :white},
      translate: {0, 0}
    ),
    rect_spec(
      {@field_size, @field_size},
      stroke: {1, :white},
      translate: {@field_size, 0}
    ),
  ]

  @graph Graph.build(font: :roboto, font_size: @text_size)
    |> add_specs_to_graph([
      text_spec(@note, translate: {300, 200}),
      rect_spec({@window_width, @window_height}),
      group_spec(@grid, translate: {20, 20})
    ])

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _opts) do
    {:ok, @graph, push: @graph}
  end

  def handle_input(event, _context, state) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, state}
  end
end
