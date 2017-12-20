defmodule Mcp23x17.DriverTest do
  use ExUnit.Case
  doctest Mcp23x17.Driver
  alias Mcp23x17.Driver

  setup do
    {:ok, _mockpid} = start_supervised(Mcp23x17.Adapters.Mock)
    
    {:ok, pid} = Mcp23x17.init_driver(33,nil,nil, Mcp23x17.Adapters.Mock)
    on_exit fn ->
      Supervisor.terminate_child(Mcp23x17.DriverSupervisor, pid)
    end
    
    {:ok, pid: pid}
  end

  test "create pin", context do
    assert match?({:ok, pin_pid} when is_pid(pin_pid),
      Driver.add_pin(context[:pid],5,:in))
  end

  test "mock read", context do
    assert match?(<<_::16>>, Driver.read(context[:pid],<< 0::8 >>,2))
  end

  test "mock write", context do
    assert Driver.write(context[:pid],<< 0::8 >>,<< 332::16 >>)
  end

  test "get addr", context do
    assert 33 == Driver.get_addr(context[:pid])
  end

end
