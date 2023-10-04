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
    GenServer.cast(SerialMotors, event)
    :ok
  end

  def handle(:autofocus) do

  end

  def handle(:capture) do

  end

  def handle(:replug) do

  end

  def handle(_) do
    :ok
  end
end
