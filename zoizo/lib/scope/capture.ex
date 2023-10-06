defmodule Scope.Capture do
  @moduledoc false

  use Rustler, otp_app: :scope, crate: "capture", target: System.get_env("RUSTLER_TARGET")

  def settings_to_args(settings) do
    Enum.flat_map(settings, fn {key, value} ->
      ["--set", "#{key}=#{value}"]
    end)
  end

  def do_capture(settings \\ %{}) do
    case System.cmd("fswebcam", ["--device", "/dev/video0", "-r", "352x288"] ++ settings_to_args(settings) ++ ["-"]) do
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
