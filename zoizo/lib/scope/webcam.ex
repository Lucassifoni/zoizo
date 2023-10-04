defmodule Scope.Webcam do
  def settings() do
    %{
      brightness: %{
        label: "Brightness",
        type: :number,
        min: -64,
        max: 64,
        default: 0,
        step: 1
      },
      contrast: %{
        label: "Contrast",
        type: :number,
        min: 0,
        max: 64,
        default: 32,
        step: 1
      },
      saturation: %{
        label: "Saturation",
        type: :number,
        min: 0,
        max: 128,
        default: 64,
        step: 1
      },
      hue: %{
        label: "Hue",
        type: :number,
        min: -40,
        max: 40,
        default: 0,
        step: 1
      },
      white_balance_automatic: %{
        label: "Auto white balance ?",
        type: :boolean
      },
      gamma: %{
        label: "Gamma",
        type: :number,
        min: 72,
        max: 500,
        default: 100,
        step: 1
      },
      gain: %{
        label: "Gain",
        type: :number,
        min: 0,
        max: 100,
        default: 0,
        step: 1
      },
      power_line_frequency: %{
        label: "Power line frequency",
        kind: :menu,
        values: [
          {0, "Disabled"},
          {1, "50 Hz"},
          {2, "60 Hz"}
        ],
      },
      white_balance_temperature: %{
        label: "White balance temperature",
        type: :number,
        min: 2800,
        max: 6500,
        default: 4600,
        step: 1
      },
      sharpness: %{
        label: "Sharpness",
        type: :number,
        min: 0,
        max: 6,
        step: 1,
        default: 2
      },
      backlight_compensation: %{
        label: "Backlight compensation",
        type: :number,
        min: 0,
        max: 2,
        step: 1,
        default: 1
      },
      auto_exposure: %{
        label: "Exposure mode",
        kind: :menu,
        values: [
          {1, "Manual"},
          {3, "Aperture priority"}
        ],
      },
      exposure_time_absolute: %{
        label: "Backlight compensation",
        type: :number,
        min: 1,
        max: 5000,
        step: 1,
        default: 156
      },
      exposure_dynamic_framerate: %{
        label: "Exposure dynamic framerate ?",
        type: :boolean
      },
    }
  end
end
