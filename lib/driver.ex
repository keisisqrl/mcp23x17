defmodule Mcp23x17.Driver do
  use GenServer
  alias Mcp23x17.Utils
  require IEx

  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.DriverRegistry, unquote(name)}}
    end
  end
    
  defstruct [:addr, :ale_pid, :ale_int, :adapter]

  @type t :: %__MODULE__{addr: integer, ale_pid: pid, ale_int: pid,
                         adapter: module}

  
  # Client

  def start_link(addr, ale_pid, ale_int, adapter, _opts \\ []) do
    new_state = %__MODULE__{addr: addr,
                        ale_pid: ale_pid,
                        ale_int: ale_int,
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

  @spec add_pin(GenServer.server,integer,
  Mcp23x17.Pin.pin_direction) :: Supervisor.on_start_child
  def add_pin(server,pin_number,direction) do
    Supervisor.start_child(
      Mcp23x17.PinSupervisor, GenServer.call(server,
        {:add_pin,pin_number,direction}))
  end
  
  
  # Callbacks

  @spec init(__MODULE__.t) :: :ok | {:error, term}
  def init(state) do
    case apply(state.adapter,:write,[state,Utils.iocon,Utils.init_config]) do
      :ok ->
        case :ok do # ElixirALE.GPIO.set_int(ale_int,:falling) do
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
    {:reply, apply(state.adapter, :read, [state, addr, len]), state}
  end

  def handle_call({:add_pin, pin_number, direction}, _from, state) do
    {:reply, [self(), pin_number, state.addr, direction], state}
  end
  
  
  # Casts
  
  def handle_cast({:write,addr,data},state) do
    apply(state.adapter, :write, [state, addr, data])
    {:noreply, state}
  end
  
  
  def handle_info({:gpio_interrupt,_,_}, state) do
    << interrupts::16, pin_states::16 >> =
      apply(state.adapter,:read,[state,Utils.intfa,4])
    Registry.dispatch(Mcp23x17.PinNotify,state.addr, fn entries ->
      for ({pid, _} <- entries) do
        send(pid,
            {:interrupt, interrupts, pin_states})
      end
    end)
    {:noreply, state}
  end
  
    
end
