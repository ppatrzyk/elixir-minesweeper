defmodule Minesweeper.Scene.Home do
  use Scenic.Scene
  require Logger

  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Minesweeper.Component.Field

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
      translate: {0, 0},
      lala: 99
    ),
    rect_spec(
      {@field_size, @field_size},
      stroke: {1, :white},
      translate: {@field_size, 0}
    ),
  ]

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
  |> Field.add_to_graph(id: :chuj)
  |> add_specs_to_graph([
    text_spec(@note, translate: {300, 300}),
    text_spec("Event received:", translate: {300, 350}, id: :event),
    button_spec("Dark", id: :btn_dark, t: {300, 400}, theme: :dark),

    # rect_spec({@window_width, @window_height}),
    group_spec(@grid, translate: {20, 20})
  ])

  @event_str "Event received: "

  def init(_, _opts) do
    {:ok, @graph, push: @graph}
  end

  def handle_input(event, _context, state) do
    Logger.info("Received event: #{inspect(event)}")
    {:noreply, state}
  end

  def filter_event(event, _, graph) do
    graph = Graph.modify(graph, :event, &text(&1, @event_str <> inspect(event)))
    {:cont, event, graph, push: graph}
  end
end
