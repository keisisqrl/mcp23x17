defmodule Mcp23x17.AdaptersDummyTest do
  use ExUnit.Case
  alias Mcp23x17.Adapters.Dummy
  alias Mcp23x17.Utils

  setup do
    {:ok, _dummypid} = start_supervised(Dummy)

    :ok
  end

  test "check init value" do
    assert << 255::8, 255::8 >> == Dummy.read(nil,Utils.iodir,2)
  end
  
  
  #test "set and check variable" do
    
  
end
