defmodule Mcp23x17.Utils do
  use Bitwise

  defmacro valid_addr?(addr) do
    quote do
      (unquote(addr) <= 39) and (unquote(addr) >= 32)
    end
  end

    
  @doc """
  Convert address pins (as integer) to base address for MCP23x17.

  Returns integer.

  ## Examples
  
  iex> Mcp23x17.base_addr(3)
  35
  iex> Mcp23x17.base_addr(8)
  ** (FunctionClauseError) no function clause matching in Mcp23x17.base_addr/1
  """
  @spec base_addr(integer) :: integer
  def base_addr(addr_pins) when addr_pins >= 0 and addr_pins < 8 do
    4
    |> bsl(3)
    |> Kernel.+(addr_pins)
  end

  @doc """
  Converts base addr to send address. Only used for SPI.

  Returns integer.

  ## Examples

  iex> Mcp23x17.send_addr(35)
  70
  iex> Mcp23x17.send_addr(40)
  ** (FunctionClauseError) no function clause matching in Mcp23x17.send_addr/1
  """
  @spec send_addr(integer) :: integer
  def send_addr(addr) when valid_addr?(addr) do
    addr <<< 1
  end

  @doc """
  Converts base addr to read address. Only used for SPI.

  Returns integer.

  ## Examples

  iex> Mcp23x17.read_addr(35)
  71
  iex> Mcp23x17.read_addr(40)
  ** (FunctionClauseError) no function clause matching in Mcp23x17.read_addr/1
  """
  @spec read_addr(integer) :: integer
  def read_addr(addr) when valid_addr?(addr) do
    send_addr(addr) + 1
  end

  @doc """
  Returns register address + 3 bytes for initial config.

  Returns 8 bytes.

  ## Examples

  iex> Mcp23x17.init_config()
  <<0x0B::8,4::4,8::4,255::8,255::8>>
  """
  @spec init_config() :: <<_::32>>
  def init_config do
    <<
    0x0B::8, # Register address: IOCON, PORTB, BANK=0
    0::1, # BANK: interleaved registers
    1::1, # MIRROR: mirror interrupts
    0::1, # SEQOP: sequential
    0::1, # DISSLW: SDA slew rate enabled (?)
    1::1, # HAEN: Enable hardware address for MCP23S17
    0::1, # ODR: Active-driver interrupt output
    0::1, # INTPOL: interrupt output active-low
    0::1, # Empty bit
    255::8, # GPPU, PORTA (pull-up enable)
    255::8 # GPPU, PORTB (pull-up enable)
    >>
  end

  def intfa do
    << 0x0e::8 >>
  end
end
