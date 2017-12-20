defmodule Mcp23x17.AdaptersMockTest do
  use ExUnit.Case
  alias Mcp23x17.Adapters.Mock
  alias Mcp23x17.Utils

  setup do
    {:ok, _mockpid} = start_supervised(Mock)

    :ok
  end

  test "check init value" do
    assert << 255::8, 255::8 >> == Mock.read(nil,Utils.iodir,2)
  end
  
  
  #test "set and check variable" do
    
  
end
