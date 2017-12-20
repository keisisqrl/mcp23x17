defmodule Mcp23x17.Adapters.MockGpio do

  def init_table do
    case :ets.info(__MODULE__) do
      :undefined ->
        :ets.new(__MODULE__,[:named_table, :public])
      _ ->
        :ok
    end
    :ok
  end

  def set_int(pinpid, direction) do
    init_table()
    :ets.insert(__MODULE__,{pinpid, direction, self()})
    :ok
  end

  def fake_int(pinpid,direction) do
    case :ets.info(__MODULE__) do
      :undefined ->
        {:error, "No subscibers"}
      _ ->
        [direction,:both]
        |> Enum.map(&(:ets.match_object(__MODULE__,{pinpid,&1,:'_'})))
        |> List.flatten
        |> Enum.map(&(elem(&1,2)))
        |> Enum.map(&(send(&1,{:gpio_interrupt,pinpid,direction})))
        :ok
    end
  end
end


    
