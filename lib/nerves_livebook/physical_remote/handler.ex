defmodule NervesLivebook.PhysicalRemote.Handler do
  use Agent
  alias NervesLivebook.Controls.Buttons
  alias NervesLivebook.Input.Handler

  def start_link(_) do
    Agent.start_link(fn () ->
      %Buttons{}
    end, name: __MODULE__)
  end

  @spec handle_serial_value(integer()) :: :ok
  def handle_serial_value(value) when is_integer(value) do
    old_state = Agent.get(__MODULE__, &(&1))
    new_state = handle_pattern(<<value>>)
    Agent.update(__MODULE__, fn (_) -> new_state end)
    events = Buttons.diff(old_state, new_state)
    for event <- events do
      Handler.handle(event)
    end
    :ok
  end

  defp truthy?(1), do: true
  defp truthy?(0), do: false

  @spec handle_pattern(<<_::8>>) :: Buttons.t()
  def handle_pattern(<<fin::1, af::1, fout::1, capture::1, right::1, left::1, down::1, up::1>>) do
    %Buttons {
      fin: truthy?(fin),
      fout: truthy?(fout),
      af: truthy?(af),
      capture: truthy?(capture),
      right: truthy?(right),
      down: truthy?(down),
      up: truthy?(up),
      left: truthy?(left),
    }
  end
end
