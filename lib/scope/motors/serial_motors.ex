defmodule Scope.Motors.SerialMotors do
  require Logger
  use GenServer

  @control <<0::2>>

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      %{
        pid: nil,
        states: %{
          enableAZ: 0,
          enableALT: 0,
          enableFOCUS: 0,
          dirAZ: 0,
          dirALT: 0,
          dirFOCUS: 0
        }
      },
      name: __MODULE__
    )
  end

  @impl true
  def handle_info({:register_port, pid}, state) do
    Logger.info("Registering serial port for the motors control")
    {:noreply, Map.put(state, :pid, pid)}
  end

  def handle_info(_, state), do: {:noreply, state}

  def handle_cast(:fin_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableFOCUS: 1, dirFOCUS: 1)

  def handle_cast(:fin_released, %{pid: p, states: s}), do: wnr(p, s, enableFOCUS: 0)

  def handle_cast(:fout_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableFOCUS: 1, dirFOCUS: 0)

  def handle_cast(:fout_released, %{pid: p, states: s}), do: wnr(p, s, enableFOCUS: 0)

  def handle_cast(:right_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableAZ: 1, dirAZ: 0)

  def handle_cast(:right_released, %{pid: p, states: s}), do: wnr(p, s, enableAZ: 0)

  def handle_cast(:left_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableAZ: 1, dirAZ: 1)

  def handle_cast(:left_released, %{pid: p, states: s}), do: wnr(p, s, enableAZ: 0)

  def handle_cast(:down_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableALT: 1, dirALT: 1)

  def handle_cast(:down_released, %{pid: p, states: s}), do: wnr(p, s, enableALT: 0)

  def handle_cast(:up_pressed, %{pid: p, states: s}),
    do: wnr(p, s, enableALT: 1, dirALT: 0)

  def handle_cast(:up_released, %{pid: p, states: s}), do: wnr(p, s, enableALT: 0)

  @impl true
  def handle_cast(_, state), do: {:noreply, state}

  def wnr(pid, states, updates) do
    new_state =
      Enum.reduce(updates, states, fn {key, val}, out ->
        Map.put(out, key, val)
      end)

    write(pid, new_state)
    {:noreply, %{pid: pid, states: new_state}}
  end

  def write(pid, %{
        enableAZ: b8,
        enableALT: b7,
        enableFOCUS: b6,
        dirAZ: b5,
        dirALT: b4,
        dirFOCUS: b3
      }) do
        IO.inspect("writing to the device : #{<<b8::1, b7::1, b6::1, b5::1, b4::1, b3::1, @control>>}")
    Circuits.UART.write(pid, ["=", <<b8::1, b7::1, b6::1, b5::1, b4::1, b3::1, @control>>])
    Circuits.UART.drain(pid)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
end
