defmodule Mcp23x17.PinTest do
  use ExUnit.Case
  doctest Mcp23x17.Pin
  alias Mcp23x17.{Driver,Pin,Utils}
  
  
  setup do
    {:ok, _dummypid} = start_supervised(Mcp23x17.Adapters.Dummy)
    
    {:ok, drvpid} = Mcp23x17.init_driver(35,nil,nil, Mcp23x17.Adapters.Dummy)
    {:ok, pinpid} = Driver.add_pin(drvpid,5,:in)
    on_exit fn ->
      Supervisor.terminate_child(Mcp23x17.DriverSupervisor, drvpid)
      Supervisor.terminate_child(Mcp23x17.PinSupervisor, pinpid)
    end
    {:ok, %{drvpid: drvpid, pinpid: pinpid}}
  end

  @tag :subscribe
  test "sub by pid", context do
    Pin.set_int(context[:pinpid],:both)
    trip_int(context[:drvpid])
    send(context[:drvpid],{:gpio_interrupt,nil,nil})

    assert_receive {:mcp23x17_interrupt,{35,5},:rising}
  end

  @tag :subscribe
  test "sub by addr", context do
    Pin.set_int({35,5})
    trip_int(context[:drvpid])
    send(context[:drvpid],{:gpio_interrupt,nil,nil})

    assert_receive {:mcp23x17_interrupt,{35,5},:rising}
  end

  test "write pin status", context do
    {:ok, out_pin} = Driver.add_pin(context[:drvpid],7,:out)

    assert :ok == Pin.write(out_pin, true)

  end

  test "refuse to write :in pin", context do
    refute :ok == Pin.write(context[:pinpid], false)
  end
  
  # Utilities

  @doc """
  Trip interrupt on pin 5.
  """
  def trip_int(driver) do
    for addr <- [Utils.intfa, Utils.intcapa] do
      Driver.write(driver,addr,<< 0::4, 1::1, 0::11 >>)
    end
  end
  
end
