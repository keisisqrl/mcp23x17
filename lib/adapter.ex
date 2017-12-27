defmodule Mcp23x17.Adapter do
  @moduledoc false

  defmodule Bus do
    @moduledoc """
    Behaviour for Bus adapters (I2C or SPI).
    """

    @callback read(Mcp23x17.Driver.t, <<_::8>>, integer) ::
    binary() | {:error, term}

    @callback write(Mcp23x17.Driver.t, << _::8 >>, binary) ::
    :ok | {:error, term}
  end

  defmodule Gpio do
    @moduledoc """
    Behavior for GPIO adapters. Mimics part of `ElixirALE.GPIO` API.
    """
    
    @callback read(GenServer.server) :: 0 | 1 | term

    @callback write(GenServer.server, 0 | 1 | boolean) :: :ok | {:error, term}
    
    @callback set_int(GenServer.server, Mcp23x17.Pin.interrupt_direction) ::
    :ok | {:error, term()}
  end
    
end
