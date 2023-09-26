# .dialyzer_ignore.exs
#
# See https://github.com/jeremyjh/dialyxir#elixir-term-format
[
  {"lib/scope/fwup.ex", :no_return, 31},
  {"lib/scope/application.ex", :pattern_match, 99}
]
