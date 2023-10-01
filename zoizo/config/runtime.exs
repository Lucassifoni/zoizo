import Config

mix_target = Nerves.Runtime.mix_target()

# Store notebooks in a writable location on the device
notebook_path =
  if mix_target == :host do
    Path.expand("priv") <> "/"
  else
    "/data/scope/"
  end

# Set the password to "nerves".
config :scope,
  authentication_mode: :password,
  password: "nerves"

# Set the Erlang distribution cookie
config :scope,
  cookie: :scope_cookie

# Endpoint configuration
port = if mix_target == :host, do: 8080, else: 80

{:ok, hostname} = :inet.gethostname()

# Setup Erlang distribution
with {_, 0} <- System.cmd("epmd", ["-daemon"]),
     {:ok, _pid} <- Node.start(:"scope@#{hostname}.local") do
  # Scope always sets the cookie, so let it set it. See the Scope application config.
  :ok
end

# Blink the LED to show that we're booting
config :delux, initial: Delux.Effects.blink(:cyan, 2)
