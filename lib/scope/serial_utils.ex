defmodule Scope.SerialUtils do
  def find_devices() do
    map = Circuits.UART.enumerate()
    Enum.reduce(map, [], fn ({name, val}, out) ->
     case val do
       %{vendor_id: 6790} -> [name | out]
       _ -> out
     end
    end)
  end

  def open_devices(names, controlling_pid) do
    for device <- names do
      {:ok, pid} = Circuits.UART.start_link()
      send(controlling_pid, {:port_to_pid, device, pid})
      Circuits.UART.open(pid, device, speed: 115200, active: false)
      Circuits.UART.controlling_process(pid, controlling_pid)
      Circuits.UART.configure(pid, framing: {Circuits.UART.Framing.Line, separator: "\r\n"}, active: true)
    end
  end

  def transfer_device_control(pid, destination_server, ack_byte) do
    server_pid = GenServer.whereis(destination_server)
    send(server_pid, {:register_port, pid})
    Circuits.UART.write(pid, ack_byte)
    Circuits.UART.drain(pid)
    Circuits.UART.controlling_process(pid, server_pid)
  end
end
