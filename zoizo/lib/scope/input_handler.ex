defmodule Scope.InputHandler do
  alias Scope.Motors.SerialMotors
  alias Scope.Controls.Event
  @spec handle(Event.t()) :: :ok
  def handle(event) when event in [
    :fin_pressed,
    :fin_released,
    :fout_pressed,
    :fout_released,
    :right_pressed,
    :right_released,
    :down_pressed,
    :down_released,
    :up_pressed,
    :up_released,
    :left_pressed,
    :left_released
  ] do
    IO.inspect(event)
    GenServer.cast(SerialMotors, event)
    :ok
  end

  def handle(:af_pressed) do

  end

  def handle(:capture_pressed) do

  end

  def handle(_) do
    :ok
  end
end
