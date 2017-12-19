defmodule Mcp23x17.DriverTest do
  use ExUnit.Case
  doctest Mcp23x17.Driver
  alias Mcp23x17.Driver

  setup_all do
    {:ok, pid} = Mcp23x17.init_driver(33,nil,nil, Mcp23x17.Adapters.Dummy)
    {:ok, pid: pid}
  end

  test "create pin", context do
    assert match?({:ok, pin_pid} when is_pid(pin_pid),
      Driver.add_pin(context[:pid],5,:in))
  end

  test "dummy read", context do
    assert match?(<<0::16>>, Driver.read(context[:pid],0,2))
  end

  test "dummy write", context do
    assert Driver.write(context[:pid],0,<< 332::16 >>)
  end
  

end
