defmodule Mcp23x17.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mcp23x17,
      version: "0.1.0",
      elixir: "~> 1.5",
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env == :prod,
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test,
                          "coveralls.post": :test, "coveralls.html": :test],
      deps: deps(),

      # Docs
      name: "Mcp23x17",
      source_url: "https://github.com/keisisqrl/mcp23x17",
      docs: [main: "Mcp23x17",
             extras: ["README.md"]]
      
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Mcp23x17, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:elixir_ale, "~> 1.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:ex_doc, "~> 0.16", only: [:dev, :test], runtime: false}
    ]
  end
end
