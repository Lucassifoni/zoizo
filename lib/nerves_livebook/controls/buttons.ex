defmodule NervesLivebook.Controls.Buttons do
  alias NervesLivebook.Controls.Buttons
  alias NervesLivebook.Controls.Event

  @type t() :: %Buttons{}
  defstruct capture: false,
            fin: false,
            fout: false,
            af: false,
            up: false,
            down: false,
            right: false,
            left: false

  @keys [:fin, :fout, :af, :capture, :right, :down, :up, :left]

  @spec diff(t(), t()) :: [Event.t()]
  def diff(a, b) do
    Enum.reduce(@keys, [], fn key, out ->
      case {Map.get(a, key), Map.get(b, key)} do
        {n, n} -> out
        {true, false} -> [String.to_atom("#{key}_pressed") | out]
        {false, true} -> [String.to_atom("#{key}_released") | out]
      end
    end)
  end
end
