defmodule Scope.InputHandler do
  alias Scope.Motors.SerialMotors
  alias Scope.Controls.Event
  @spec handle(Event.t()) :: :ok
  def handle(event) do
    IO.inspect(event)
    GenServer.cast(SerialMotors, event)
    :ok
  end
end
