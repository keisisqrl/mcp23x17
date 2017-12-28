defmodule Mcp23x17.Adapters.ElixirALE.I2C do
  alias ElixirALE.I2C
  @behaviour Mcp23x17.Adapter.Bus
  @moduledoc """
  `Mcp23x17.Adapter.Bus` implementation for `ElixirALE.I2C`.

  For use with the MCP23017.
  """

  @doc """
  Read `len` bytes starting at `regaddr`.
  """
  @spec read(Mcp23x17.Driver.t, << _::8 >>, integer) :: binary | {:error, term}
  def read(driver, regaddr, len)  do
    I2C.write_read_device(driver.xfer_pid, driver.addr, regaddr, len)
  end

  @doc """
  Write `data` starting at `regaddr`.
  """
  @spec write(Mcp23x17.Driver.t, << _::8 >>, binary) :: :ok | {:error, term}
  def write(driver, regaddr, data) do
    I2C.write_device(driver.xfer_pid, driver.addr,
      << regaddr::binary, data::binary >>)
  end

end
