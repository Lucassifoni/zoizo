defmodule Scope.WebcamServer do
  alias Phoenix.PubSub
  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, {false, nil}, name: __MODULE__)
    Process.send_after(pid, :capture, 16)
    {:ok, pid}
  end

  def handle_info({:capture_done, new_pic}, {true, _pic}) do
    Process.send_after(self(), :capture, 16)
    {:noreply, {false, new_pic}}
  end

  def handle_info(:do_capture, {_, p}) do
    pid = self()
    Task.start(fn () ->
      pic = Zoizo.capture()
      PubSub.broadcast(Zoizoui.PubSub, "frames", {:got_pic, pic})
      Process.send(pid, {:capture_done, pic}, [])
    end)
    {:noreply, {true, p}}
  end

  def handle_info(:capture, {true, pic}) do
    Process.send_after(self(), :capture, 16)
    {:noreply, {true, pic}}
  end

  def handle_info(:capture, {false, pic}) do
    Process.send(self(), :do_capture, [])
    {:noreply, {true, pic}}
  end

  def handle_call(:pic, _from, {state, pic}) do
    {:reply, pic, {state, pic}}
  end

  def get_pic(pid), do: GenServer.call(pid, :pic)
end
