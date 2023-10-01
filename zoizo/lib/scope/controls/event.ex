defmodule Scope.Controls.Event do
  @type t() ::
          :fin_pressed
          | :fin_released
          | :fout_pressed
          | :fout_released
          | :af_pressed
          | :af_released
          | :capture_pressed
          | :capture_released
          | :right_pressed
          | :right_released
          | :down_pressed
          | :down_released
          | :up_pressed
          | :up_released
          | :left_pressed
          | :left_released
end
