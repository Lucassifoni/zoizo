defmodule Scope.SerialServer do
  alias Scope.Motors.SerialMotors
  alias Scope.PhysicalRemote.SerialRemote
  alias Scope.SerialUtils
  require Logger
  use GenServer

  @remote_discriminant ";"
  @motors_discriminant "<"
  @ack "="

  def start_link(arg) do
    {:ok, pid} = GenServer.start_link(__MODULE__, arg, name: __MODULE__)
    devices = SerialUtils.find_devices() |> IO.inspect()
    SerialUtils.open_devices(devices, pid)
    {:ok, pid}
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_info({:port_to_pid, device, pid}, state) do
    IO.inspect("Port to pid")
    {:noreply, Map.put(state, device, {pid, :untransfered})}
  end

  def handle_info({:circuits_uart, port, @motors_discriminant}, state) do
    handle_potential_control_transfer(port, SerialMotors, state)
  end

  def handle_info({:circuits_uart, port, @remote_discriminant}, state) do
    handle_potential_control_transfer(port, SerialRemote, state)
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp handle_potential_control_transfer(port, module, state) do
    case Map.get(state, port) do
      {pid, :untransfered} ->
        SerialUtils.transfer_device_control(pid, module, @ack)
        {:noreply, Map.put(state, port, {pid, :transfered})}

      _ ->
        {:noreply, state}
    end
  end
end
