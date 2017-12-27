defmodule Mcp23x17.AdaptersMockBusTest do
  use ExUnit.Case
  alias Mcp23x17.Adapters.MockBus
  alias Mcp23x17.Utils

  setup do
    {:ok, _mockpid} = start_supervised(MockBus)

    :ok
  end

  test "check init value" do
    assert << 255::8, 255::8 >> == MockBus.read(nil,Utils.iodir,2)
  end
  
  
  #test "set and check variable" do
    
  
end
