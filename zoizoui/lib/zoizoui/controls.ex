defmodule Zoizoui.Controls do
  alias Phoenix.PubSub

  def publish(msg) do
    PubSub.broadcast(Zoizoui.PubSub, "web_input", msg)
  end
end
