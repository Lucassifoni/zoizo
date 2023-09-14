import Config

mix_target = Nerves.Runtime.mix_target()

# Store notebooks in a writable location on the device
notebook_path =
  if mix_target == :host do
    Path.expand("priv") <> "/"
  else
    "/data/livebook/"
  end

# Set the password to "nerves".
config :livebook,
  authentication_mode: :password,
  password: "nerves"

# Set the Erlang distribution cookie
config :livebook,
  cookie: :nerves_livebook_cookie

# Endpoint configuration
port = if mix_target == :host, do: 8080, else: 80

{:ok, hostname} = :inet.gethostname()

# Setup Erlang distribution
with {_, 0} <- System.cmd("epmd", ["-daemon"]),
     {:ok, _pid} <- Node.start(:"livebook@#{hostname}.local") do
  # Livebook always sets the cookie, so let it set it. See the Livebook application config.
  :ok
end

# Blink the LED to show that we're booting
config :delux, initial: Delux.Effects.blink(:cyan, 2)
