defmodule Scope.Capture do
  @moduledoc false

  use Rustler, otp_app: :scope, crate: "capt", target: System.get_env("RUSTLER_TARGET")

  def do_capture() do
    case capture() do
      {[], []} -> :error
      a -> {:ok, a}
    end
    :error
  end
  defp capture(), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
