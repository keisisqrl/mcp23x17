defmodule Mcp23x17 do
  @moduledoc """
  Interact with an MCP23x17 module through Elixir ALE.
  """
  use Application

  def start(_,_) do
    Mcp23x17.Supervisor.start_link([])
  end

  def init_driver(addr,ale_pid,ale_int,adapter) do
    Supervisor.start_child(Mcp23x17.DriverSupervisor,
      [addr,ale_pid,ale_int,adapter])
  end
  
  
end
