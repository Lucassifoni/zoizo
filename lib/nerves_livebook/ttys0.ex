defmodule NervesLivebook.Ttys0 do
  use GenServer

  @spec start_link() :: GenServer.on_start()
  def start_link() do
    {:ok, pid} = Circuits.UART.start_link()
    Circuits.UART.open(pid, "ttyS0", speed: 9600, active: false)
    Circuits.UART.write(pid, "")
    Circuits.UART.drain(pid)
    {:ok, pid}
  end

  def init(_) do
    {:ok, nil}
  end
end
