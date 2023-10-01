defmodule Scope.WebuiCommunication do
  use GenServer
  alias Scope.InputHandler
  alias Phoenix.PubSub

  def start_link(_opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: Scope.WebuiCommunication)
    Process.send(pid, :subscribe, [])
    {:ok, pid}
  end

  def handle_info(:subscribe, state) do
    PubSub.subscribe(Zoizoui.PubSub, "web_input")
    {:noreply, state}
  end

  def handle_info(a, state) do
    InputHandler.handle(a)
    {:noreply, state}
  end

  def init(a) do
    {:ok, a}
  end
end
