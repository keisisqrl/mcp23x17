defmodule Mcp23x17.PinTest do
  use ExUnit.Case
  doctest Mcp23x17.Pin
  alias Mcp23x17.{Driver,Pin,Utils}

  @intpid self()

  @drvaddr 35
  @inpin 5
  @outpin 7
  
  setup do
    {:ok, _dummypid} = start_supervised(Mcp23x17.Adapters.Dummy)
    
    {:ok, drvpid} = Mcp23x17.init_driver(35, nil, @intpid,
      Mcp23x17.Adapters.Dummy)
    {:ok, pinpid} = Driver.add_pin(drvpid, @inpin, :in)
    {:ok, outpid} = Driver.add_pin(drvpid, @outpin, :out)
    on_exit fn ->
      Supervisor.terminate_child(Mcp23x17.DriverSupervisor, drvpid)
      Supervisor.terminate_child(Mcp23x17.PinSupervisor, pinpid)
      Supervisor.terminate_child(Mcp23x17.PinSupervisor, outpid)
    end
    {:ok, %{drvpid: drvpid, pinpid: pinpid, outpid: outpid}}
  end

  @tag :subscribe
  test "sub by pid", context do
    Pin.set_int(context[:pinpid],:both)
    trip_int(context[:drvpid])
    Mcp23x17.Adapters.MockGpio.fake_int(@intpid,:falling)

    assert_receive {:mcp23x17_interrupt,{@drvaddr,@inpin},:rising}
  end

  @tag :subscribe
  test "sub by addr", context do
    Pin.set_int({35,5})
    trip_int(context[:drvpid])
    Mcp23x17.Adapters.MockGpio.fake_int(@intpid,:falling)

    assert_receive {:mcp23x17_interrupt,{@drvaddr,@inpin},:rising}
  end

  @tag :subscribe
  test "no interrupt on rising", context do
    Pin.set_int({35,5})
    trip_int(context[:drvpid])
    Mcp23x17.Adapters.MockGpio.fake_int(@intpid,:rising)

    refute_receive {:mcp23x17_interrupt,{@drvaddr,@inpin},:rising}
  end
  
  @tag :write
  test "write pin status", context do

    assert :ok == Pin.write(context[:outpid], true)

  end

  @tag :write
  test "write pin by tuple" do

    assert :ok == Pin.write({35,7}, true)

  end

  @tag :write
  test "refuse to write :in pin", context do
    refute :ok == Pin.write(context[:pinpid], false)
  end
  
  # Utilities

  @doc """
  Trip interrupt on pin 5.
  """
  def trip_int(driver) do
    for addr <- [Utils.intfa, Utils.intcapa] do
      offset = @inpin - 1
      postfix = 16 - @inpin
      Driver.write(driver,addr,<< 0::size(offset), 1::1, 0::size(postfix) >>)
    end
  end
  
end
