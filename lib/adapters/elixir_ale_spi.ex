defmodule Mcp23x17.Adapters.ElixirALE.SPI do
  alias ElixirALE.SPI
  import Mcp23x17.Utils
  @behaviour Mcp23x17.Adapter.Bus

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
