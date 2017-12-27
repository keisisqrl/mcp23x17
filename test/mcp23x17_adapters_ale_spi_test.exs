defmodule Mcp23x17.AdaptersElixirALESPITest do
  use ExUnit.Case
  alias Mcp23x17.Adapters.ElixirALE.SPI
  import Mock

  setup_with_mocks([
    {ElixirALE.SPI,
     [],
     [transfer: fn(_pid, data) ->
       len = byte_size data
       << 0::unit(8)-size(len) >>
     end]}]) do
    {:ok, driver: %Mcp23x17.Driver{adapter: SPI, addr: 33,
                                   xfer_pid: :xfer_pid, int_pid: :int_pid}}
  end

  test "read/3", context do
    assert << 0::unit(8)-size(4) >> ==
      SPI.read(context[:driver], Mcp23x17.Utils.intfa, 4)
    assert called ElixirALE.SPI.transfer(:xfer_pid,
      << 33::7, 1::1, Mcp23x17.Utils.intfa::binary, 0::unit(8)-size(4) >>)
  end

  test "write/3", context do
    assert :ok == SPI.write(context[:driver], Mcp23x17.Utils.intfa,
      << 293::16 >>)
    assert called ElixirALE.SPI.transfer(:xfer_pid,
      << 33::7, 0::1, Mcp23x17.Utils.intfa::binary, 293::16 >>)
  end
  
end

      
        
