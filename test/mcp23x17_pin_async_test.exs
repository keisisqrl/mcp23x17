defmodule Mcp23x17.PinAsyncTest do
  use ExUnit.Case, async: true
  alias Mcp23x17.Pin

  describe "modify_info/1" do
    test "set bit" do
      for x <- Range.new(0,15),
        y <- Range.new(15,0),
        x + y == 15 do
            assert << 0::size(x), 1::1, 0::size(y)>> ==
              Pin.modify_info(x+1,<<0::16>>,true)
      end
    end
  end

  describe "extract_info/1" do
    test "extract bit" do
      for x <- Range.new(0,15),
        y <- Range.new(15,0),
        x + y == 15 do
            assert Pin.extract_info(x+1,
              << 0::size(x), 1::1, 0::size(y) >>)
      end
    end
  end

end
