defmodule NervesLivebook.PhysicalRemote.Screen do
  @width 100
  @height 100
  @vals 4
  @f File.read!("/Users/lucas/Desktop/signal-2023-09-18-163548_002.pgm")

  def sample_picture() do
    lines = String.split(@f, "\n")
    lines = Enum.slice(lines, 4..9999)
    out = Enum.map(lines, fn v -> trunc(String.to_integer(v) / 64) end) |> Enum.chunk_every(4) |> Enum.map(fn [a, b, c, d] ->
      <<a::2, b::2, c::2, d::2>>
    end)
    out
  end
end
