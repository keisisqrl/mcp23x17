defmodule Mcp23x17.PinSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__,[],name: __MODULE__)
  end

  def init(_) do
    Supervisor.init([
      Supervisor.child_spec(Pin,
        start: {Pin, :start_link, []})
    ], strategy: :simple_one_for_one)
  end

end
