defmodule ZoizouiWeb.ControlsLive do
  # In Phoenix apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="left" id="foobutton-left">gauche</button>
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="right" id="foobutton-right">droite</button>
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="up" id="foobutton-up">haut</button>
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="down" id="foobutton-down">bas</button>
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="fin" id="foobutton-fin">fin</button>
    <button class="bg-red-500 p-4" phx-hook="FooButton" data-buttonid="fout" id="foobutton-fout">fout</button>
    """
  end

  def mount(_params, %{}, socket) do
    {:ok, socket}
  end

  @button_events [
    "fin_pressed",
    "fin_released",
    "fout_pressed",
    "fout_released",
    "af_pressed",
    "af_released",
    "capture_pressed",
    "capture_released",
    "right_pressed",
    "right_released",
    "down_pressed",
    "down_released",
    "up_pressed",
    "up_released",
    "left_pressed",
    "left_released",
  ]
  def handle_event(event, _, socket) when event in @button_events do
    Zoizoui.Controls.foo(String.to_atom(event))
    {:noreply, socket}
  end

  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end
