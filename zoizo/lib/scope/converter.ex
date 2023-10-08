defmodule Scope.Converter do
  @moduledoc false

  use Rustler, otp_app: :scope, crate: "capture", target: System.get_env("RUSTLER_TARGET")

  def do_convert(bytes) do
    case convert(bytes) do
      {[], []} -> :error
      a -> {:ok, a}
    end
  end

  defp convert(_bytes), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
