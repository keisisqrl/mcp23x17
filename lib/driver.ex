defmodule Mcp23x17.Driver do
  use GenServer
  alias Mcp23x17.Utils
  require IEx

  @doctest_addr 33

  @moduledoc """
  Driver function for MCP23x17 IC. Can interact with SPI or I2C, using an
  adapter defined under `Mcp23x17.Adapters`.
  """

  @gpio Application.get_env(:mcp23x17, :gpio_driver)

  defstruct [:addr, :xfer_pid, :int_pid, :adapter]

  @type t :: %__MODULE__{addr: integer, xfer_pid: pid, int_pid: pid,
                         adapter: module}

  @doc """
  Translates address of MCP23x17 IC to `GenServer.start_link/3`-compatible
  `name` property.
  """
  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.DriverRegistry, unquote(name)}}
    end
  end

  # Client
  @spec start_link([term], list) :: GenServer.on_start
  def start_link([addr, xfer_pid, int_pid, adapter], _opts \\ []) do
    new_state = %__MODULE__{addr: addr,
                        xfer_pid: xfer_pid,
                        int_pid: int_pid,
                        adapter: adapter}
    GenServer.start_link(__MODULE__, new_state,
      name: reg_name(addr))
  end

  @doc """
  Read `len` bytes from the associated MCP23x17 starting at register `addr`
  """
  @spec read(GenServer.server, <<_::8>>, integer) :: binary()
  def read(server, addr, len) do
    GenServer.call(server, {:read, addr, len})
  end

  @doc """
  Write bits to the associated MCP23x17 IC at register `addr`.
  """
  @spec write(GenServer.server, <<_::8>>, bitstring) :: :ok
  def write(server, addr, data) do
    GenServer.cast(server, {:write, addr, data})
  end

  @doc """
  Return the address of the associated MCP23x17 IC.

  ## Examples

      iex> {:ok, drvpid} =
      ...> Mcp23x17.init_driver([33, nil, nil, Mcp23x17.Adapters.MockBus])
      iex> Mcp23x17.Driver.get_addr(drvpid)
      33
      iex> Mcp23x17.Driver.release(drvpid)
      :ok
  """
  @spec get_addr(GenServer.server) :: integer
  def get_addr(server) do
    GenServer.call(server, :get_addr)
  end

  @doc """
  Spawn associated `Mcp23x17.Pin` process

  ## Examples

      iex> {:ok, drvpid} =
      ...> Mcp23x17.init_driver([33, nil, nil, Mcp23x17.Adapters.MockBus])
      iex> {:ok, pinpid} = Mcp23x17.Driver.add_pin(drvpid, 5, :out)
      iex> is_pid pinpid
      true
      iex> Mcp23x17.Driver.release(drvpid)
      :ok
  """
  @spec add_pin(GenServer.server, integer,
  Mcp23x17.Pin.pin_direction) :: Supervisor.on_start_child
  def add_pin(server, pin_number, direction) do
    Supervisor.start_child(
      Mcp23x17.PinSupervisor, GenServer.call(server,
        {:add_pin, pin_number, direction}))
  end

  @doc """
  Terminate via `Mcp23x17.DriverSupervisor` and release associated
  `Mcp23x17.Pin`s.

  ## Examples

      iex> {:ok, drvpid} =
      ...> Mcp23x17.init_driver([33, nil, nil,
      ...> Mcp23x17.Adapters.MockBus])
      iex> {:ok, pinpid} = Mcp23x17.Driver.add_pin(drvpid, 8, :out)
      iex> Process.alive? pinpid
      true
      iex> Mcp23x17.Driver.release(drvpid)
      :ok
      iex> Process.alive? pinpid
      false
  """
  @spec release(pid) :: :ok | {:error, :not_found}
  def release(pid) do
    Registry.dispatch(Mcp23x17.PinNotify, get_addr(pid), fn entries ->
        for {pinpid, _} <- entries do
          Supervisor.terminate_child(Mcp23x17.PinSupervisor, pinpid)
        end
    end)
    Supervisor.terminate_child(
      Mcp23x17.DriverSupervisor, pid
    )
  end

  # Callbacks

  @spec init(__MODULE__.t) :: {:ok, __MODULE__.t} | {:stop, term}
  def init(state) do
    case state.adapter.write(state, Utils.iocon, Utils.init_config) do
      :ok ->
        case @gpio.set_int(state.int_pid, :falling) do
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

  def handle_call({:read, addr, len}, _from, state) do
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

  def handle_cast({:write, addr, data}, state) do
    state.adapter.write(state, addr, data)
    {:noreply, state}
  end

  def handle_info({:gpio_interrupt, _, _}, state) do
    << interrupts::16, pin_states::16 >> =
      state.adapter.read(state, Utils.intfa, 4)
    Registry.dispatch(Mcp23x17.PinNotify, state.addr, fn entries ->
      for ({pid, _} <- entries) do
        send(pid,
            {:interrupt, interrupts, pin_states})
      end
    end)
    {:noreply, state}
  end

end
