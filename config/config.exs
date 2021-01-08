use Mix.Config

config :minesweeper, :viewport, %{
  name: :main_viewport,
  size: {370, 370},
  default_scene: {Minesweeper.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "minesweeper"]
    }
  ]
}
