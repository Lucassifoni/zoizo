import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  provisioning: "config/provisioning.conf"

if Mix.env() != :test do
  # Set log level to warning by default to reduce output except for testing
  # The unit tests rely on info level log messages.
  config :logger, level: :warning
end

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1603310828"

# Add mime type to upload notebooks with `Phoenix.LiveView.Upload`
config :mime, :types, %{
  "text/plain" => ["livemd"]
}

if Mix.target() == :host do
  import_config "host.exs"
else
  import_config "target.exs"
end
