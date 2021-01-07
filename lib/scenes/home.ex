defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  # import Scenic.Components

  @note "Init example scenic"
  @text_size 24

  @width 1024
  @height 720

  @grid [
    rect_spec(
      {50, 60},
      fill: :khaki,
      stroke: {4, :green}
    ),
  ]

  @graph Graph.build(font: :roboto, font_size: @text_size)
    |> add_specs_to_graph([
      text_spec(@note, translate: {300, 200}),
      rect_spec({@width, @height}),
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
