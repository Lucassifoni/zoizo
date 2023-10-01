defmodule Zoizoui.Controls do
  alias Phoenix.PubSub

  defp publish(msg) do
    PubSub.broadcast(Zoizoui.PubSub, "web_input", msg)
  end
  def foo(msg) do
    publish(msg)
  end
end
