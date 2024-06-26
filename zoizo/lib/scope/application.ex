defmodule Scope.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    initialize_data_directory()

    setup_wifi()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scope.Supervisor]

    children =
      [
        Scope.UI,
        Scope.PhysicalRemote.Handler,
        Scope.PhysicalRemote.SerialRemote,
        Scope.Motors.SerialMotors,
        Scope.WebuiCommunication,
        Scope.SerialServer,
        Scope.WebcamServer
      ] ++ target_children(Nerves.Runtime.mix_target())

    Supervisor.start_link(children, opts)
  end

  defp initialize_data_directory() do
    destination_dir = "/data/scope"
    source_dir = Application.app_dir(:scope, "priv")

    # Best effort create everything
    _ = File.mkdir_p(destination_dir)
  end

  defp symlink(source_dir, destination_dir, filename) do
    source = Path.join(source_dir, filename)
    dest = Path.join(destination_dir, filename)

    _ = File.rm(dest)
    _ = File.ln_s(source, dest)
  end

  if Mix.target() == :host do
    defp setup_wifi(), do: :ok
  else
    defp setup_wifi() do
      kv = Nerves.Runtime.KV.get_all()

      if true?(kv["wifi_force"]) or wlan0_unconfigured?() do
        ssid = kv["wifi_ssid"]
        passphrase = kv["wifi_passphrase"]

        unless empty?(ssid) do
          #_ = VintageNetWiFi.quick_configure(ssid, passphrase)
          :ok
        end
      end
    end

    defp wlan0_unconfigured?() do
      "wlan0" in VintageNet.configured_interfaces() and
        VintageNet.get_configuration("wlan0") == %{type: VintageNetWiFi}
    end

    defp true?(""), do: false
    defp true?(nil), do: false
    defp true?("false"), do: false
    defp true?("FALSE"), do: false
    defp true?(_), do: true

    defp empty?(""), do: true
    defp empty?(nil), do: true
    defp empty?(_), do: false
  end

  if Mix.target() == :host do
    defp target_children(_), do: [Scope.Ttys0]
  else
    defp target_children(:srhub), do: [Scope.WiFiMonitor]
    defp target_children(_), do: [Scope.WiFiMonitor]
  end
end
