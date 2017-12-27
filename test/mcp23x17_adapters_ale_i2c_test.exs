defmodule Mcp23x17.AdaptersElixirALEI2CTest do
  use ExUnit.Case
  alias Mcp23x17.Adapters.ElixirALE.I2C
  import Mock

  setup_with_mocks([
    {ElixirALE.I2C,
     [],
     [write_read_device: fn(_pid, _addr, _regaddr, len) ->
       << 0::unit(8)-size(len) >> end,
      write_device: fn(_pid, _addr, _data) -> :ok end]}]) do
    {:ok, driver: %Mcp23x17.Driver{adapter: I2C, addr: :test_addr,
                                   xfer_pid: :xfer_pid, int_pid: :int_pid}}
  end

  test "read/3", context do
    assert << 0::unit(8)-size(4) >> ==
      I2C.read(context[:driver], Mcp23x17.Utils.intfa, 4)
    assert called ElixirALE.I2C.write_read_device(
      :xfer_pid, :test_addr, Mcp23x17.Utils.intfa, 4)
  end

  test "write/3", context do
    assert :ok == I2C.write(context[:driver], Mcp23x17.Utils.intfa,
      << 293::16 >>)
    assert called ElixirALE.I2C.write_device(:xfer_pid, :test_addr,
      << Mcp23x17.Utils.intfa::binary, 293::16 >>)
  end
  
end

      
        
