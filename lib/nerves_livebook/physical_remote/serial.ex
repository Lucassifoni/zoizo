defmodule NervesLivebook.PhysicalRemote.Serial do
  alias NervesLivebook.PhysicalRemote.Serial
  alias NervesLivebook.PhysicalRemote.Screen
  alias NervesLivebook.PhysicalRemote.Handler
  use GenServer

  if Mix.target() == :host do
    @target_device "/dev/cu.usbserial-120"
  else
    @target_device "ttyUSB0"
  end

  @spec find_device() :: {:ok, binary()} | {:error, nil}
  def find_device() do
    if Map.has_key?(Circuits.UART.enumerate(), @target_device) do
      {:ok, @target_device}
    else
      {:error, nil}
    end
  end

  @spec start_link(any) :: GenServer.on_start()
  def start_link(_) do
    case find_device() do
      {:ok, name} -> {:ok, pid} = Circuits.UART.start_link()
      {:ok, gpid} = GenServer.start_link(__MODULE__, pid, name: __MODULE__)
      Circuits.UART.open(pid, name, speed: 115_200, active: false)
      Circuits.UART.controlling_process(pid, gpid)
      Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r\n"}, active: true)
      IO.inspect([pid, gpid])
      {:ok, gpid}
      {:error, nil} ->
        IO.inspect("Did not find the device")
        IO.inspect(Circuits.UART.enumerate())
        :ignore
    end
  end

  @impl true
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

  def demo() do
    pid = GenServer.whereis(NervesLivebook.PhysicalRemote.Serial)
    :timer.sleep(1000)
    write_image(pid)
  end

  def clear() do
    pid = GenServer.whereis(NervesLivebook.PhysicalRemote.Serial)
    send(pid, :erase_screen)
  end

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end
end
