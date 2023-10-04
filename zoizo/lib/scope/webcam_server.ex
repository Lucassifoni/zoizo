defmodule Scope.WebcamServer do
  @moduledoc """
  Server used to take the continuous small webcam frames.
  """
  use GenServer
  alias Phoenix.PubSub
  alias Scope.PhysicalRemote.SerialRemote
  defstruct capturing: false, last_pic: nil, running: false

  @type t() :: __MODULE__

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{
      capturing: false,
      last_pic: nil,
      running: true,
    }, name: __MODULE__)
    Process.send_after(pid, :capture, 16)
    {:ok, pid}
  end

  @spec not_capturing(t()) :: t()
  def not_capturing(%__MODULE__{} = state), do: Map.put(state, :capturing, false)
  @spec capturing(t()) :: t()
  def capturing(%__MODULE__{} = state), do: Map.put(state, :capturing, true)
  @spec set_new_pic(t(), binary()) :: t()
  def set_new_pic(%__MODULE__{} = state, pic), do: Map.put(state, :last_pic, pic)
  @spec pic(t()) :: t()
  def pic(%__MODULE__{} = state), do: Map.get(:state, pic)
  @spec running(t()) :: t()
  def running(%__MODULE__{} = state), do: Map.put(:state, :running, true)
  @spec not_running(t()) :: t()
  def not_running(%__MODULE__{} = state), do: Map.put(:state, :running, false)

  @spec broadcast_tiny_pic(pid(), binary()) :: :ok | :noconnect | :nosuspend
  def broadcast_tiny_pic(pid, tiny_pic_pixels) do
    PubSub.broadcast(Zoizoui.PubSub, "frames", {:got_pic, pic})
    case GenServer.whereis(SerialRemote) do
      nil -> :ok
      p -> Process.send(p, {:picture, tiny_pic_pixels}, [])
    end
    Process.send(pid, {:capture_done, pic}, [])
  end

  @impl true
  def handle_info({:capture_done, new_pic}, %__MODULE__{} = state) do
    Process.send_after(self(), :capture, 16)
    {:noreply, state |> not_capturing |> set_new_pic(new_pic) }
  end

  def handle_info(:do_capture, %__MODULE__{running: false} = state), do: {:noreply, state}
  def handle_info(:do_capture, %__MODULE__{} = state) do
    pid = self()
    Task.start(fn () ->
      case Scope.Capture.do_capture() do
        :error ->
          Process.send(pid, {:capture_done, nil}, [])
          :ok
        {:ok, {pic, tiny_pic_pixels}} ->
          broadcast_tiny_pic(pid, tiny_pic_pixels)
          :ok
      end
    end)
    {:noreply, state |> capturing}
  end

  def handle_info(:capture, %__MODULE__{capturing: true} = state) do
    if state.running do
      Process.send_after(self(), :capture, 16)
    end
    {:noreply, state}
  end

  def handle_info(:capture, %__MODULE__{capturing: false} = state) do
    if state.running do
      Process.send(self(), :do_capture, [])
      {:noreply, state |> capturing}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call(:pic, _from, %__MODULE__{} = state) do
    {:reply, pic(pic), state}
  end

  @impl true
  def handle_cast(:play, _, %__MODULE__{} = state) do
    Process.send(self(), :capture, [])
    {:noreply, state |> running}
  end

  @impl true
  def handle_cast(:pause, _, %__MODULE__{} = state) do
    {:noreply, state |> not_running}
  end

  @spec get_pic() :: binary()
  def get_pic(), do: GenServer.call(Scope.WebcamServer, :pic)

  @spec play() :: :ok
  def play(), do: GenServer.cast(Scope.WebcamServer, :play)

  @spec pause() :: :ok
  def pause(), do: GenServer.cast(Scope.WebcamServer, :pause)
end
