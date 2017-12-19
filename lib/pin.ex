defmodule Mcp23x17.Pin do
  use GenServer
  alias Mcp23x17.{Driver,Utils}
  
  defstruct [:driver, :pin_number, :driver_addr]

  @type t :: %__MODULE__{driver: pid, pin_number: integer,
                         driver_addr: integer}

  @type pin_direction :: :in | :out

  @type interrupt_direction :: :both | :falling | :rising

  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.PinRegistry, unquote(name)}}
    end
  end
  
  
  # Client

  @spec start_link(pid, integer, integer, pin_direction) :: GenServer.on_start
  def start_link(driver,pin_number, driver_addr, direction, _opts \\ []) do
    state = %__MODULE__{driver: driver, pin_number: pin_number,
                        driver_addr: driver_addr}
    GenServer.start_link(__MODULE__,[state, direction],
      name: reg_name({driver_addr,pin_number}))
  end

  @doc """
  Turn on interrupts for the pin. Mimics ElixirALE GPIO interface, but 
  has a default of :both if no direction is given.
  """

  @spec set_int(pid|tuple, interrupt_direction) :: {:ok, term} |
  {:error, term}
  def set_int(server, direction \\ :both)

  def set_int(server, direction) when is_tuple(server) do
    set_int(GenServer.whereis(reg_name(server)),direction)
  end

  def set_int(server, direction) when is_pid(server) and direction in
  [:rising,
   :falling,
   :both] do
    Registry.register(Mcp23x17.PinSubscribers, server, direction)
  end

  @spec write(pid|tuple, 0|1|true|false) :: :ok | {:error, term}
  def write(server, value) do
    GenServer.call(server, {:write,
                            case value do
                              0 ->
                                false
                              false ->
                                false
                              _ ->
                                true
                            end
                           })
  end
  
  
  # Callbacks

  @spec init([atom]) :: {:ok,__MODULE__.t}
  def init([state, direction]) do
    Registry.register(Mcp23x17.PinNotify,
      state.driver_addr,[])
    cur_reg = Driver.read(state.driver,Utils.iodir,2)
    new_reg = modify_info(state.pin_number,cur_reg,
    (direction == :in))
    Driver.write(state.driver,Utils.iodir,new_reg)
    {:ok, state}
  end

  def handle_call({:write, value}, _from, state) do
    cur_reg = Driver.read(state.driver,Utils.iodir,2)
    {:reply, if extract_info(state.pin_number,cur_reg) do
        {:error, "Pin is input"}
      else
        Driver.write(state.driver,Utils.iodir,
          modify_info(state.pin_number,cur_reg,value))
        :ok
      end,
     state
    }
  end

  # Infos
  
  @spec handle_info({:interrupt,integer,integer},
    __MODULE__.t) :: {:noreply, __MODULE__.t}
  def handle_info({:interrupt,interrupts,pin_states}, state) do
    if extract_info(state.pin_number, << interrupts::16 >>) do
      pin_transition = if extract_info(
            state.pin_number, << pin_states::16 >>) do
        :rising
      else
        :falling
      end
      Registry.dispatch(Mcp23x17.PinSubscribers,
        self(), fn recipients ->
          for {pid, subscription} <- recipients do
            if subscription in [pin_transition, :both] do
              send(pid, {:mcp23x17_interrupt,
                         {state.driver_addr, state.pin_number},
                         pin_transition})
            end
          end
        end)
    end
    {:noreply, state}
  end

  # Utilities
  
  @spec extract_info(integer,<< _::16 >>) :: boolean
  defp extract_info(pin_number, registers) do
    offset = pin_number - 1
    rem = 16 - pin_number
    << _::size(offset), retval::1, _::size(rem) >> = registers 
    case retval do
      1 ->
        true
      0 ->
        false
    end
  end

  @spec modify_info(integer,<<_::16>>, boolean) :: <<_::16>>
  defp modify_info(pin_number, registers, val) do
    newval = if val, do: 1, else: 0
    offset = pin_number - 1
    rem = 16 - pin_number
    << prefix::size(offset), _oldval::1, postfix::size(rem) >> = registers
    << prefix, newval::1, postfix >>
  end
  
  
end
