defmodule Mcp23x17.Adapters.Dummy do
  @moduledoc """
  Dummy adapter for testing.
  """

  def write(driver,addr,data) do
    :ok
  end

  def read(driver,addr,len) do
    << 0::size(len) >>
  end

end

