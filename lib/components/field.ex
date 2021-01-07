defmodule Minesweeper.Component.Field do
  use Scenic.Component, has_children: false

  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.ViewPort
  import Scenic.Primitives

  # def info(data) do
  #   """
  #   #{IO.ANSI.red()}Button data must be a bitstring: initial_text
  #   #{IO.ANSI.yellow()}Received: #{inspect(data)}
  #   #{IO.ANSI.default_color()}
  #   """
  # end

  def verify(scene) when is_atom(scene), do: {:ok, scene}
  def verify({scene, _} = data) when is_atom(scene), do: {:ok, data}
  def verify(_), do: :invalid_data

  def init(current_scene, opts) do
    width = 30
    height = 30

    # build the graph
    graph =
      Graph.build(font: :roboto, font_size: 24)
      |> rect({ width, height} )

    state = %{
      graph: graph,
      pressed: false,
      contained: false,
      id: id
    }

    {:ok, state, push: graph}
  end

  def handle_input(
        {:cursor_enter, _uid},
        _context,
        %{
          pressed: true
        } = state
      ) do
    state = Map.put(state, :contained, true)
    {:noreply, state, push: update_color(state)}
  end

  def handle_input(
        {:cursor_exit, _uid},
        _context,
        %{
          pressed: true
        } = state
      ) do
    state = Map.put(state, :contained, false)
    {:noreply, state, push: update_color(state)}
  end

  # --------------------------------------------------------
  def handle_input({:cursor_button, {:left, :press, _, _}}, context, state) do
    state =
      state
      |> Map.put(:pressed, true)
      |> Map.put(:contained, true)

    update_color(state)

    ViewPort.capture_input(context, [:cursor_button, :cursor_pos])

    {:noreply, state, push: update_color(state)}
  end

  # --------------------------------------------------------
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        context,
        %{pressed: pressed, contained: contained, id: id} = state
      ) do
    state = Map.put(state, :pressed, false)
    update_color(state)

    ViewPort.release_input(context, [:cursor_button, :cursor_pos])

    if pressed && contained do
      send_event({:click, id})
    end

    {:noreply, state, push: update_color(state)}
  end

  def handle_input(_event, _context, state) do
    {:noreply, state}
  end

  defp update_color(%{graph: graph, pressed: false, contained: false}) do
    Graph.modify(graph, :btn, fn p ->
      p
      |> Primitive.put_style(:fill, :gray)
    end)
  end

  defp update_color(%{graph: graph, pressed: false, contained: true}) do
    Graph.modify(graph, :btn, fn p ->
      p
      |> Primitive.put_style(:fill, :gray)
    end)
  end

  defp update_color(%{graph: graph, pressed: true, contained: false}) do
    Graph.modify(graph, :btn, fn p ->
      p
      |> Primitive.put_style(:fill, :gray)
    end)
  end

  defp update_color(%{graph: graph, pressed: true, contained: true}) do
    Graph.modify(graph, :btn, fn p ->
      Primitive.put_style(p, :fill, :white)
    end)
  end

end
