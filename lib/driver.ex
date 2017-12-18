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
    IEx.pry()
    new_state = %__MODULE__{addr: addr,
                        ale_pid: ale_pid,
                        ale_int: ale_int,
                        adapter: adapter}
    GenServer.start_link(__MODULE__,new_state,
      name: reg_name(addr))
  end
  


  
  # Callbacks

  @spec init(__MODULE__.t) :: :ok | {:error, term}
  def init(state) do
    case apply(state.adapter,:write,[state,Utils.init_config]) do
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

  def handle_info({:gpio_interrupt,_,_}, state) do
    << interrupts::16, pin_states::16 >> =
      apply(state.adapter,:read,[state,Utils.intfa,4])
    {:noreply, state}
  end
  
    
end
