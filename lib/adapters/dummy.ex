defmodule Mcp23x17.Adapters.Dummy do
  @moduledoc """
  Dummy adapter for testing.
  """

  def write(_driver,_content) do
    :ok
  end

  def read(_driver,_addr,_num) do
    :ok
  end

end

