defmodule Scope.WebcamServer do
  @moduledoc """
  Server used to take the continuous small webcam frames.
  """
  use GenServer
  alias Phoenix.PubSub
  alias Scope.PhysicalRemote.SerialRemote
  defstruct converting: false, port: nil, settings: %{}, buffer: []

  @type t() :: __MODULE__

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %__MODULE__{
      port: nil,
      converting: false,
      buffer: [],
      settings: %{},
    }, name: __MODULE__)
    Process.send_after(pid, :open_port, 500)
    {:ok, pid}
  end

  def not_converting(%__MODULE__{} = state), do: Map.put(state, :converting, false)
  def converting(%__MODULE__{} = state), do: Map.put(state, :converting, true)

  def apply_setting(%__MODULE__{} = state, setting, value) do
    settings = state.settings |> Map.put(setting, value)
    Map.put(state, :settings, settings)
  end
  def clear_settings(%__MODULE__{} = state), do: Map.put(state, :settings, %{})

  def broadcast_pics(pid, tiny_pic_pixels) do
    case GenServer.whereis(SerialRemote) do
      nil -> :ok
      p -> Process.send(p, {:picture, tiny_pic_pixels}, [])
    end
    Process.send(pid, :conversion_done, [])
  end

  def handle_info(:open_port, state) do
    args = ~w(-f v4l2 -video_size 320x240 -i /dev/video0 -r 25 -f mjpeg -)
    port = Port.open({:spawn_executable, "/usr/bin/ffmpeg"}, [:binary, args: args])
    {:noreply, Map.put(state, :port, port)}
  end
  def handle_info({:convert, data}, state) do
    if not(state.converting) do
      pid = self()
      Task.start(fn () ->
        case Scope.Converter.do_convert(data) do
          :error ->
            Process.send(pid, :conversion_done, [])
            :ok
          {:ok, tiny_pic_pixels} ->
            broadcast_pics(pid, tiny_pic_pixels)
            :ok
        end
      end)
      {:noreply, state |> converting}
    else
      {:noreply, state}
    end
  end

  def parse_jpeg(<<0xFF, 0xD9>>, acc) do
   (<<255::8, 216::8, 255::8>> <> Enum.into(Enum.reverse(acc), <<>>, fn byte -> <<byte :: 8>> end) <> <<0xFF::8, 0xD9::8>>)

  end
  def parse_jpeg(<<byte::8>> <> rest, acc), do: parse_jpeg(rest, [byte | acc])
  def handle_info({port, {:data, data}}, %__MODULE__{port: port} = state) do
    case data do
      <<255, 216, 255>> <> d -> out = parse_jpeg(d, [])
      pid = self()
      Task.start(fn () ->
        Process.send(pid, {:convert, out}, [])
        PubSub.broadcast(Zoizoui.PubSub, "frames", {:got_pic, Base.encode64(out, padding: false)})
      end)
      _ -> :ok
    end
    {:noreply, state}
  end

  @impl true
  def handle_info(:conversion_done, %__MODULE__{} = state) do
    {:noreply, state |> not_converting }
  end

  def handle_cast({:setting, setting, value}, %__MODULE__{} = state) do
    {:noreply, state |> apply_setting(setting, value)}
  end
end
