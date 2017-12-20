defmodule Mcp23x17.Driver do
  use GenServer
  alias Mcp23x17.Utils
  require IEx

  @gpio Application.get_env(:mcp23x17, :gpio_driver)
  
  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.DriverRegistry, unquote(name)}}
    end
  end
    
  defstruct [:addr, :xfer_pid, :int_pid, :adapter]

  @type t :: %__MODULE__{addr: integer, xfer_pid: pid, int_pid: pid,
                         adapter: module}

  
  # Client

  def start_link(addr, xfer_pid, int_pid, adapter, _opts \\ []) do
    new_state = %__MODULE__{addr: addr,
                        xfer_pid: xfer_pid,
                        int_pid: int_pid,
                        adapter: adapter}
    GenServer.start_link(__MODULE__,new_state,
      name: reg_name(addr))
  end
  
  def read(server,addr,len) do
    GenServer.call(server,{:read, addr, len})
  end
  
  def write(server,addr,data) do
    GenServer.cast(server,{:write, addr, data})
  end

  @spec get_addr(GenServer.server) :: integer
  def get_addr(server) do
    GenServer.call(server,:get_addr)
  end
  

  @spec add_pin(GenServer.server,integer,
  Mcp23x17.Pin.pin_direction) :: Supervisor.on_start_child
  def add_pin(server,pin_number,direction) do
    Supervisor.start_child(
      Mcp23x17.PinSupervisor, GenServer.call(server,
        {:add_pin,pin_number,direction}))
  end
  
  
  # Callbacks

  @spec init(__MODULE__.t) :: {:ok, __MODULE__.t} | {:stop, term}
  def init(state) do
    case state.adapter.write(state,Utils.iocon,Utils.init_config) do
      :ok ->
        case @gpio.set_int(state.int_pid,:falling) do
          :ok ->
            {:ok, state}
          {:error, err} ->
            {:stop, err}
        end
      {:error, err} ->
        {:stop, err}
    end
    
  end

  # Calls

  def handle_call({:read,addr,len},_from,state) do
    {:reply, state.adapter.read(state, addr, len), state}
  end

  def handle_call({:add_pin, pin_number, direction}, _from, state) do
    {:reply, [self(), pin_number, state.addr, direction], state}
  end

  @spec handle_call(:get_addr, GenServer.from,
    __MODULE__.t) :: {:reply, integer, __MODULE__.t}
  def handle_call(:get_addr, _from, state) do
    {:reply, state.addr, state}
  end
  
  # Casts
  
  def handle_cast({:write,addr,data},state) do
    state.adapter.write(state, addr, data)
    {:noreply, state}
  end
  
  
  def handle_info({:gpio_interrupt,_,_}, state) do
    << interrupts::16, pin_states::16 >> =
      state.adapter.read(state,Utils.intfa,4)
    Registry.dispatch(Mcp23x17.PinNotify,state.addr, fn entries ->
      for ({pid, _} <- entries) do
        send(pid,
            {:interrupt, interrupts, pin_states})
      end
    end)
    {:noreply, state}
  end
  
    
end
