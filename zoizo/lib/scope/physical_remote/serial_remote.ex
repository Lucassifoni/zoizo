defmodule Scope.PhysicalRemote.SerialRemote do
  alias Scope.PhysicalRemote.Handler
  require Logger
  use GenServer

  def start_link(_) do
   GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def handle_info({:register_port, pid}, _) do
    IO.inspect("Registering serial port for the remote control")
    {:noreply, {pid, :idle}}
  end
  def handle_info({:circuits_uart, _, "%"}, b), do: {:noreply, b}
  def handle_info({:circuits_uart, _, "." <> rest}, b) do
    case Integer.parse(rest, 10) do
      {n, ""} -> Handler.handle_serial_value(n)
        :ok
      _ -> :ok
    end
    {:noreply, b}
  end
  def handle_info({:circuits_uart, _, _}, b), do: {:noreply, b}
  def handle_info({:picture, data}, {pid, :idle}) do
    erase_screen(pid)
    remapped = data |> Enum.map(&(trunc(&1 / 64))) |> Enum.chunk_every(4) |> Enum.map(fn [a,b,c,d] ->
      <<a::2, b::2, c::2, d::2>>
    end)
    loop_on_pic_data(remapped |> Enum.chunk_every(24), pid)
    {:noreply, {pid, :active}}
  end
  def handle_info({:picture, _}, {pid, :active}), do: {:noreply, {pid, :active}}
  def handle_info({:loop_on_pic_data, data}, {pid, :active}) do
    new_state = loop_on_pic_data(data, pid)
    {:noreply, {pid, new_state}}
  end
  def handle_info(:erase_screen, {pid, :idle}) do
    erase_screen(pid)
    {:pid, :idle}
  end
  def handle_info(_, nil) do
    {:noreply, nil}
  end

  def erase_screen(pid) do
    Circuits.UART.write(pid, [?+])
    Circuits.UART.drain(pid)
  end

  def loop_on_pic_data([a | b], pid) do
    Circuits.UART.write(pid, a)
    Circuits.UART.drain(pid)
    Process.send_after(self(), {:loop_on_pic_data, b}, 50)
    :active
  end
  def loop_on_pic_data([], _pid), do: :idle

  def clear(pid), do: send(pid, :erase_screen)

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end
end
