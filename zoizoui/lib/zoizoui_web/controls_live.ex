defmodule ZoizouiWeb.ControlsLive do
  defstruct state: :idle, settings: %{}

  alias Phoenix.PubSub
  # In Phoenix apps, the line is typically: use MyAppWeb, :live_view
  use ZoizouiWeb, :live_view
  alias Phoenix.LiveView.JS

  def render(assigns) do
    import ZoizouiWeb.Icons

    ~H"""
    <div class="fixed inset-0 bg-slate-200">
    <canvas id="canvas" class="w-full h-auto bg-slate-700 mb-2"></canvas>
    <div class="relative h-80 pb-8">
      <%= if @state.state == :idle do %>
        <div class="w-36 h-36 absolute left-[50%] -translate-x-[50%] mx-auto top-[.25em]">
          <button class="absolute p-1 m-0 bottom-0 left-12 w-12 h-12" phx-hook="FooButton" id="down" data-buttonid="down"><.zicon icon="FLECHE-BAS" /></button>
          <button class="absolute p-1 m-0 right-0 top-12 w-12 h-12" phx-hook="FooButton" id="right" data-buttonid="right"><.zicon icon="FLECHE-DROITE" /></button>
          <button class="absolute p-1 m-0 left-0 top-12 w-12 h-12" phx-hook="FooButton" id="left" data-buttonid="left"><.zicon icon="FLECHE-GAUCHE" /></button>
          <button class="absolute p-1 m-0 left-12 w-12 h-12" phx-hook="FooButton" id="up" data-buttonid="up"><.zicon icon="FLECHE-HAUT" /></button>
          <button class="absolute p-1 m-0 top-12 left-12 w-12 h-12" phx-click="capture"><.zicon icon="PHOTO" /></button>
        </div>
        <div class="w-80 h-16 absolute left-[50%] -translate-x-[50%] mx-auto top-60">
          <span class="text-xs absolute -top-1 left-[50%] -translate-x-[50%]">FOCUS</span>
          <div class="h-[1px] border-dotted border-t-[1px] border-t-black left-2 right-2 absolute top-8"></div>
          <button class="absolute top-3" phx-hook="FooButton" id="fin" data-buttonid="fin"><.zicon icon="FOCUS-MOINS" /></button>
          <button class="absolute top-3 left-[50%] -translate-x-[50%]" phx-click="autofocus"><.zicon icon="FOCUS-AF" /></button>
          <button class="absolute top-3 right-0" phx-hook="FooButton" id="fout" data-buttonid="fout"><.zicon icon="FOCUS-PLUS" /></button>
        </div>
          <div class="absolute top-2 right-2"><button phx-click="go_to_pictures"><.zicon icon="PHOTOTHEQUE" /></button></div>
          <div  class="absolute top-2 left-2"><button phx-click="go_to_settings"><.zicon icon="REGLAGES" /></button></div>
      <% end %>

      <%= if @state.state == :settings do %>
      <div class="absolute bottom-0 px-4 top-2 right-0 left-10 overflow-y-scroll">
        <%= for {setting, meta} <- @state.settings do %>
        <div class="relative mb-[.5em]">
          <span class="text-sm" for={"input-#{setting}"}><%= meta.label %></span>
          <%= case meta.type do %>
            <% :number -> %>
              <div class="relative">
                <span class="absolute text-xs left-0"><%= meta.min %></span>
                <span class="absolute text-xs right-0"><%= meta.max %></span>
                <input phx-hook="hackyhook" data-setting={setting} id={setting} min={meta.min} max={meta.max} value={meta.value} step={meta.step} class="relative top-[.75em] text-sm w-full" type="range">
              </div>
            <% :boolean -> %>
              <input phx-hook="hackyhook" data-setting={setting} type="checkbox" id={setting} checked={meta.value}>
            <% :menu -> %>
              <div class="flex">
              <%= for {key, val} <- meta.values do %>
                <label class="block text-xs pl-2 mr-2">
                <input phx-hook="hackyhook" data-setting={setting} type="radio" class="mr-1" id={"#{setting}-#{key}"} name={"input-#{setting}"} value={key} checked={key == meta.value}>
                <%= val %>
                </label>
              <% end %>
              </div>
            <% _ -> %>
              unimplemented
          <% end %>
        </div>
        <% end %>
        </div>
      <% end %>

    <%= if @state.state != :idle do %>
      <div class="absolute top-2 left-2"><button phx-click="go_to_idle"><.zicon icon="CROIX" /></button></div>
    <% end %>
    </div>
    </div>
    """
  end

  def default_state() do
    %__MODULE__{
      settings: Zoizoui.Webcam.settings(),
      state: :idle
    }
  end

  def transition(socket, fun) do
    assign(socket, :state, fun.(socket.assigns.state))
  end
  def go_to_pictures(%__MODULE__{} = state), do: state |> Map.put(:state, :pictures)
  def go_to_settings(%__MODULE__{} = state), do: state |> Map.put(:state, :settings)
  def go_to_idle(%__MODULE__{} = state), do: state |> Map.put(:state, :idle)
  def publish_noreply(socket, event) do
    Zoizoui.Controls.publish(event)
    {:noreply, socket}
  end
  def update_setting(socket, setting, value) do
    Zoizoui.Controls.publish({:setting, setting, value})
    settings = socket.assigns.state.settings |> put_in([setting, :value], value)
    state = socket.assigns.state |> Map.put(:settings, settings)
    socket |> assign(:state, state)
  end
  def mount(_params, %{}, socket) do
    PubSub.subscribe(Zoizoui.PubSub, "frames")
    {:ok, socket |> assign(:state, default_state())}
  end

  def handle_info({:got_pic, pic}, socket) do
    {:noreply,
     push_event(socket, "js-frame", %{
       frameData: pic
     })}
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
    "left_released"
  ]
  def handle_event(event, _, socket) when event in @button_events, do: publish_noreply(socket, String.to_atom(event))
  def handle_event("go_to_settings", _, socket), do: {:noreply, transition(socket, &go_to_settings/1)}
  def handle_event("go_to_pictures", _, socket), do: {:noreply, transition(socket, &go_to_pictures/1)}
  def handle_event("go_to_idle", _, socket), do: {:noreply, transition(socket, &go_to_idle/1)}
  def handle_event("replug", _, socket), do: publish_noreply(socket, :replug)
  def handle_event("autofocus", _, socket), do: publish_noreply(socket, :autofocus)
  def handle_event("capture", _, socket), do: publish_noreply(socket, :capture)
  def handle_event("value_changed", %{"setting" => setting, "value" => v}, socket) when setting in [
    "brightness",
    "contrast",
    "saturation",
    "hue",
    "white_balance_automatic",
    "gamma",
    "gain",
    "power_line_frequency",
    "white_balance_temperature",
    "sharpness",
    "backlight_compensation",
    "auto_exposure",
    "exposure_time_absolute",
    "exposure_dynamic_framerate"
  ] do
    key = String.to_atom(setting)
    details = socket.assigns.state.settings |> Map.get(key)
    new_value = case details.type do
      :boolean -> v
      _ -> String.to_integer(v)
    end
    {:noreply, socket |> update_setting(key, new_value)}
  end
end
