defmodule Mcp23x17.Pin do
  use GenServer

  defstruct [:driver, :pin_number]

  @type t :: %__MODULE__{driver: pid, pin_number: integer}

  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.PinRegistry, unquote(name)}}
    end
  end

  # Client

  @spec start_link(Mcp23x17.Driver.t,integer) :: GenServer.on_start
  def start_link(driver,pin_number,_opts \\ []) do
    GenServer.start_link(__MODULE__,[driver,pin_number],
      name: reg_name(driver.addr))
  end

  # Callbacks

  @spec init(Mcp23x17.Driver.t,integer) :: {:ok,__MODULE__.t}
  def init(driver,pin_number) do
    {:ok, %__MODULE__{driver: driver, pin_number: pin_number}}
  end
  
  
end
