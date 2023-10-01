defmodule Scope.PhysicalRemote.SerialRemote do
  alias Scope.PhysicalRemote.SerialRemote
  alias Scope.PhysicalRemote.Screen
  alias Scope.PhysicalRemote.Handler
  require Logger
  use GenServer

  def start_link(_) do
   GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def handle_info({:register_port, pid}, _) do
    Logger.info("Registering serial port for the remote control")
    {:noreply, pid}
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
  def handle_info({:picture, data}, pid) do
    erase_screen(pid)
    loop_on_pic_data(data |> Enum.chunk_every(24), pid)
    {:noreply, pid}
  end
  def handle_info({:loop_on_pic_data, data}, pid) do
    loop_on_pic_data(data, pid)
    {:noreply, pid}
  end
  def handle_info(:erase_screen, pid) do
    erase_screen(pid)
  end

  def erase_screen(pid) do
    Circuits.UART.write(pid, [?+])
    Circuits.UART.drain(pid)
    {:noreply, pid}
  end

  def loop_on_pic_data([a | b], pid) do
    Circuits.UART.write(pid, a)
    Circuits.UART.drain(pid)
    Process.send_after(self(), {:loop_on_pic_data, b}, 50)
    :ok
  end
  def loop_on_pic_data([], _pid), do: :ok

  def write_image(pid) do
    send(pid, {:picture, Screen.sample_picture() })
    :ok
  end

  def clear(pid) do
    send(pid, :erase_screen)
  end

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end
end
