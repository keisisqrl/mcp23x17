defmodule Mcp23x17.PinSupervisor do
  use Supervisor

  @moduledoc false

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([
      Supervisor.child_spec(Mcp23x17.Pin,
        start: {Mcp23x17.Pin, :start_link, []})
    ], strategy: :simple_one_for_one)
  end

end
