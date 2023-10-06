defmodule Scope.SerialServer do
  alias Scope.Motors.SerialMotors
  alias Scope.PhysicalRemote.SerialRemote
  alias Scope.SerialUtils
  require Logger
  use GenServer

  @remote_discriminant ";"
  @motors_discriminant "<"
  @ack "="

  def find_devices() do
    map = Circuits.UART.enumerate()

    Enum.reduce(map, [], fn {name, val}, out ->
      if String.contains?(name, "wchusbserial") do
        out
      else
        case val do
          %{vendor_id: 6790} -> [name | out]
          _ -> out
        end
      end
    end)
  end

  def handle_cast({:unregister_port, name}, state) do
    {:noreply, Map.drop(state, [name])}
  end

  def transfer_device_control(pid, destination_server, ack_byte) do
    server_pid = GenServer.whereis(destination_server)
    send(server_pid, {:register_port, pid})
    Circuits.UART.write(pid, ack_byte)
    Circuits.UART.drain(pid)
    Circuits.UART.controlling_process(pid, server_pid)
  end

  def start_link(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    Process.send_after(pid, :lookup_devices, 500)
    {:ok, pid}
  end

  def init(arg) do
    {:ok, arg}
  end

  def handle_info(:lookup_devices, state) do
    devices = find_devices()

    unregistered_devices =
      devices
      |> Enum.filter(fn d ->
        is_nil(Map.get(state, d))
      end)

    state =
      Enum.reduce(unregistered_devices, state, fn (dev, st) ->
        {:ok, pid} = Circuits.UART.start_link()
        Circuits.UART.open(pid, dev, speed: 115_200, active: false)
        Circuits.UART.controlling_process(pid, self())

        Circuits.UART.configure(pid,
          framing: {Circuits.UART.Framing.Line, separator: "\r\n"},
          active: true
        )

        Map.put(st, dev, {:undetermined, pid})
      end)

    Process.send_after(self(), :lookup_devices, 500)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, port, @motors_discriminant}, state) do
    handle_potential_control_transfer(port, SerialMotors, state)
  end

  def handle_info({:circuits_uart, port, @remote_discriminant}, state) do
    handle_potential_control_transfer(port, SerialRemote, state)
  end

  def handle_info(msg, state) do
    {:noreply, state}
  end

  defp handle_potential_control_transfer(port, module, state) do
    case Map.get(state, port) do
      {:undetermined, pid} ->
        transfer_device_control(pid, module, @ack)
        {:noreply, Map.put(state, port, {:transfered, pid})}

      _ ->
        {:noreply, state}
    end
  end
end
