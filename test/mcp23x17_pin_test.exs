defmodule Mcp23x17.PinTest do
  use ExUnit.Case
  doctest Mcp23x17.Pin
  alias Mcp23x17.{Driver,Pin}

  defmodule Pin5Dummy do
    alias Mcp23x17.Adapters.Dummy
    
    def read(_,_,4) do
      << 0::4,1::1,0::11,0::4,1::1,0::11 >>
    end
    def read(state,addr,len) do
      Dummy.read(state,addr,len)
    end

    def write(state,addr,val) do
      Dummy.write(state,addr,val)
    end
    
  end
  
  
  setup do
    {:ok, drvpid} = Mcp23x17.init_driver(35,nil,nil, Pin5Dummy)
    {:ok, pinpid} = Driver.add_pin(drvpid,5,:in)
    on_exit fn ->
      Supervisor.terminate_child(Mcp23x17.DriverSupervisor, drvpid)
      Supervisor.terminate_child(Mcp23x17.PinSupervisor, pinpid)
    end
    {:ok, %{drvpid: drvpid, pinpid: pinpid}}
  end

  test "sub by pid", context do
    Pin.set_int(context[:pinpid],:both)
    send(context[:drvpid],{:gpio_interrupt,nil,nil})

    assert_receive {:mcp23x17_interrupt,{35,5},:rising}
  end
  
end
