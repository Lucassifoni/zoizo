defmodule Scope.Capture do
  @moduledoc false

  use Rustler, otp_app: :scope, crate: "capture", target: System.get_env("RUSTLER_TARGET")

  def do_capture() do
    case System.cmd("fswebcam", ["-"]) do
      {bytes, 0} -> case capture(bytes) do
        {[], []} -> :error
        a -> {:ok, a}
      end
      _ -> :error
    end |> IO.inspect()
  end
  defp capture(_bytes), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
