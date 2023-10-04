defmodule Scope.Capture do
  @moduledoc false

  use Rustler, otp_app: :scope, crate: "capture", target: System.get_env("RUSTLER_TARGET")

  def do_capture() do
    case System.cmd("fswebcam", ["--device", "/dev/video0", "-"]) do
      {bytes, 0} -> case capture(bytes) do
        {[], []} -> :error
        a -> {:ok, a}
      end
      _ -> :error
    end
  end

  def do_capture_big_frame() do
    case System.cmd("fswebcam", ["--device", "/dev/video2", "-r", "1280x720", "-"]) do
      {bytes, 0} -> case capture(bytes) do
        {[], []} -> :error
        a -> {:ok, a}
      end
      _ -> :error
    end
  end
  defp capture(_bytes), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
