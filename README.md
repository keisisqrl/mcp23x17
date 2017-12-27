# Mcp23x17

This library interfaces with a Microchip MCP23x17-series GPIO expander, mimicing
the API published by the [ElixirALE](https://hex.pm/packages/elixir_ale)
library.

Adapters are[^1] provided for ElixirALE I2C, SPI, and GPIO interfaces. A
behavior will be published to potentially allow interaction with other low-level
interfaces.

Currently (2017-12-26) ElixirALE is still a little too deeply baked into the
`Mcp23x17.Driver` interface.

During development, documentation is available through [Github
Pages](https://keisisqrl.github.io/mcp23x17/index.html).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mcp23x17` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mcp23x17, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc) and published on
[HexDocs](https://hexdocs.pm). Once published, the docs can be found at
[https://hexdocs.pm/mcp23x17](https://hexdocs.pm/mcp23x17).

[^1]: TODO 2017-12-26: will be
