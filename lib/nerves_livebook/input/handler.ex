defmodule NervesLivebook.Input.Handler do
  alias NervesLivebook.Controls.Event
  @spec handle(Event.t()) :: :ok
  def handle(event) do
    IO.inspect(event)
    :ok
  end
end
