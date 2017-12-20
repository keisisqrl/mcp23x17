defmodule Mcp23x17.Adapters.Mock do
  @moduledoc """
  Mock adapter for testing.
  """
  use Agent

  def start_link(_) do
    Agent.start_link(fn ->
      << 255::8, 255::8, 0::unit(8)-size(20) >>
    end, name: __MODULE__)
  end

  @spec write(any,<< _::8 >>, bitstring) :: :ok
  def write(_driver,<< addr::8 >>,data) do
    bitlen = bit_size(data)
    postlen = (8 * 22) - (bitlen + (addr * 8))
    Agent.update(__MODULE__, fn state ->
      << prefix::binary-size(addr), _::size(bitlen),
      postfix::bitstring-size(postlen) >> = state
      << prefix::binary, data::bitstring-size(bitlen), postfix::bitstring >>
    end
    )
  end

  @spec read(any, << _::8 >>, integer) :: binary
  def read(_driver,<< addr::8 >>,len) do
    state = Agent.get(__MODULE__, &(&1))
    postlen = 22 - (len + addr)
    << _::binary-size(addr), retval::binary-size(len),
      _postfix::binary-size(postlen) >> = state
    retval
  end

end

