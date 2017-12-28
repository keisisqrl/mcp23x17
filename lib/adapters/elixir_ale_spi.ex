defmodule Mcp23x17.Adapters.ElixirALE.SPI do
  alias ElixirALE.SPI
  import Mcp23x17.Utils
  @behaviour Mcp23x17.Adapter.Bus
  @moduledoc """
  `Mcp23x17.Adapter.Bus` implementation for `ElixirALE.SPI`.

  For use with the MCP23S17.
  """

  @doc """
  Read `len` bytes starting at `regaddr`.
  """
  @spec read(Mcp23x17.Driver.t, <<_::8>>, integer) :: binary | {:error, term}
  def read(driver, regaddr, len) do
    case SPI.transfer(driver.xfer_pid,
          << read_addr(driver.addr)::8,
          regaddr::binary, 0::unit(8)-size(len) >>) do
      << _::16, retval::binary-size(len) >> ->
        retval
      {:error, err} ->
        {:error, err}
    end
  end

  @doc """
  Write `data` starting at `regaddr`.
  """
  @spec write(Mcp23x17.Driver.t, << _::8 >>, binary) :: :ok | {:error, term}
  def write(driver, regaddr, data) do
    case SPI.transfer(driver.xfer_pid,
          << send_addr(driver.addr)::8,
          regaddr::binary, data::binary >>) do
      {:error, err} ->
        {:error, err}
      << _::binary >> ->
        :ok
    end
  end
end
