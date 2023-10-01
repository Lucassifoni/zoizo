defmodule Scope do
  @moduledoc """
  Scope firmware
  """

  require Logger

  @doc """
  Return the Scope version

  This returns the version as a string.
  """
  @spec version() :: String.t()
  def version() do
    Application.spec(:scope, :vsn)
    |> to_string()
  end

  @doc """
  Convenience method for checking internet-connectivity for a Scope
  """
  @spec check_internet!() :: :ok
  if Mix.target() == :host do
    def check_internet!(), do: :ok
  else
    def check_internet!() do
      unless VintageNet.get(["connection"]) == :internet,
        do: raise("Please check that at least one network interface can reach the internet")

      :ok
    end
  end

  def ssh_check_pass(_provided_username, provided_password) do
    correct_password = Application.get_env(:scope, :password, "nerves")

    provided_password == to_charlist(correct_password)
  end

  def ssh_show_prompt(_peer, _username, _service) do
    msg = """
    https://github.com/scope/scope

    ssh #{Node.self()} # Use password "nerves"
    """

    {~c"Scope", to_charlist(msg), ~c"Password: ", false}
  end
end
