defmodule Mcp23x17.DriverSupervisor do
  use Supervisor
  alias Mcp23x17.Driver

  defmacro reg_name(name) do
    quote do
      {:via, Registry, {Mcp23x17.DriverRegistry, name}}
    end
  end
  

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    Supervisor.init([
      Supervisor.child_spec(Driver,
        start: {Driver, :start_link, []})
    ], strategy: :simple_one_for_one)
  end
end
