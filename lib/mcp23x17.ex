defmodule Mcp23x17 do
  @moduledoc """
  Interact with an MCP23x17 module through Elixir ALE.
  """
  use Application

  @doc false
  def start(_, _) do
    Mcp23x17.Supervisor.start_link([])
  end

  @doc ~S"""
  Create a `Mcp23x17.Driver` in the supervision tree and return it.

  Always call this with the base (7-bit) address of the chip. This can be 
  calculated from the A pins using `Mcp23x17.Utils.base_addr/1`.

  ## Examples

      iex> Mcp23x17.init_driver([33, nil, nil, Mcp23x17.Adapters.Mock])
      {:ok, #Pid<>}
  """
#  @spec init_driver([integer, pid, pid, module]) :: Supervisor.on_start_child
  @spec init_driver([term]) :: Supervisor.on_start_child
  def init_driver([addr, ale_pid, ale_int, adapter]) do
    Supervisor.start_child(Mcp23x17.DriverSupervisor,
      [[addr, ale_pid, ale_int, adapter]])
  end

end
