import Config

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn, init: [:nerves_runtime, :nerves_pack]

config :zoizoui, ZoizouiWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [port: 80],
  server: true,
  url: [host: "nerves.local"],
  check_origin: false,
  cache_static_manifest: "priv/static/cache_manifest.json",
  code_reloader: false,
  render_errors: [
    formats: [html: ZoizouiWeb.ErrorHTML, json: ZoizouiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Zoizoui.PubSub,
  live_view: [signing_salt: "VGWxWb2g"],
  secret_key_base: "DYwwesYRFdqHznJDKKnhZtmilBK1HRd4MWhNK9RxMXRTu4je4aAjqtwNjurxYye7"

config :phoenix, :json_library, Jason

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Zoizoui.Finch

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger, RamoopsLogger]

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

# Save a short report on shutdowns just in case it wasn't intentional
config :nerves, :erlinit, shutdown_report: "/data/last_shutdown.txt"

# Advance the timestamp as soon as possible to get the date closer
# to the real one especially on RTC-less devices.
config :nerves, :erlinit, update_clock: true

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

config :nerves_ssh,
  daemon_option_overrides: [
    {:pwdfun, &Scope.ssh_check_pass/2},
    {:auth_method_kb_interactive_data, &Scope.ssh_show_prompt/3}
  ]

config :mdns_lite,
  instance_name: "Scope",

  # Use MdnsLite's DNS bridge feature to support mDNS resolution in Erlang
  dns_bridge_enabled: true,
  dns_bridge_port: 53,
  dns_bridge_recursive: false,
  # Respond to "nerves-1234.local` and "nerves.local"
  hosts: [:hostname, "nerves"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "http",
      transport: "tcp",
      port: 80
    },
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

# Common VintageNet configuration
#
# See bbb.exs, rpi0.exs, etc. for device-specific configuration.
#
# regulatory_domain - 00 (global), change to "US", etc.
# additional_name_servers - Set to try mdns_lite's DNS bridge first
config :vintage_net,
  regulatory_domain: "00",
  additional_name_servers: [{127, 0, 0, 53}]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{Mix.target()}.exs"
