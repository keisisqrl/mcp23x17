defmodule Mcp23x17.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([
      {Registry,[keys: :unique,name: Mcp23x17.DriverRegistry]},
      {Registry,[keys: :duplicate,name: Mcp23x17.PinRegistry]},
      {Mcp23x17.DriverSupervisor,[]},
      {Mcp23x17.PinSupervisor,[]}
    ], strategy: :one_for_all)
  end
end
