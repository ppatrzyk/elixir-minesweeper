defmodule Minesweeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :minesweeper,
      version: "0.1.0",
      elixir: "~> 1.11",
      build_embedded: true,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Minesweeper, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.10"},
      {:scenic_driver_glfw, "~> 0.10", targets: :host},
    ]
  end
end
