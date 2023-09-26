defmodule Scope.MixProject do
  use Mix.Project

  @app :scope
  @version "0.10.1"
  @source_url "https://github.com/scope/scope"

  @all_targets [:mqscope]
  @rust_toolchain "riscv64gc-unknown-linux-gnu"
  @linker_path Path.expand("~/.nerves/artifacts/nerves_toolchain_riscv64_nerves_linux_gnu-linux_x86_64-1.8.0/bin/riscv64-nerves-linux-gnu-gcc")

  # Libraries that use MMAL on the Raspberry Pi won't work with the Raspberry
  # Pi 4. The Raspberry Pi 4 uses DRM and libcamera.

  # See the BlueHeron repository for the boards that it supports.

  # Targets supporting cellular modems

  # TFLite isn't building on the RPi and RPi0 (armv6), so just don't include it there.

  # Instruct the compiler to create deterministic builds to minimize
  # differences between firmware versions. This helps delta firmware update
  # compression.
  System.put_env("ERL_COMPILER_OPTIONS", "deterministic")

  def project do

    case System.get_env("MIX_TARGET", "host") do
      "mqscope" ->
        System.put_env("RUSTFLAGS", "-C linker=#{@linker_path}")
        System.put_env("RUSTLER_TARGET", @rust_toolchain)
        :ok
      _ -> System.put_env("RUSTLER_TARGET", "x86_64-unknown-linux-gnu")
    end

    [
      app: @app,
      description: "Develop on embedded devices with Scope and Nerves",
      author: "https://github.com/scope/scope/graphs/contributors",
      version: @version,
      package: package(),
      elixir: "~> 1.14",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host, "phx.server": :host],
      dialyzer: dialyzer(),
      docs: docs(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application do
    [
      mod: {Scope.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ex_unit]
    ]
  end

  # The nice part about posting to hex is that documentation links work when you're
  # calling Scope functions.
  defp package do
    %{
      files: [
        "CHANGELOG.md",
        "lib",
        "mix.exs",
        "README.md",
        "LICENSE",
        "assets",
        "priv"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps do
    [
      # Dependencies for host and target
      {:nerves, "~> 1.10", runtime: false},
      {:shoehorn, "~> 0.9.0"},
      {:ring_logger, "~> 0.9"},
      {:toolshed, "~> 0.3.0"},
      {:jason, "~> 1.2"},
      {:nerves_runtime, "~> 0.13.0"},
      {:plug, "~> 1.12"},
      {:vintage_net, "~> 0.13"},

      # Pull in commonly used libraries as a convenience to users.
      {:bmp280, "~> 0.2", targets: @all_targets},
      {:circuits_gpio, "~> 1.0"},
      {:circuits_i2c, "~> 1.0"},
      {:circuits_spi, "~> 1.0 or ~> 0.1"},
      {:circuits_uart, "~> 1.3"},
      {:delux, "~> 0.2"},
      {:hts221, "~> 1.0", targets: @all_targets},
      {:input_event, "~> 1.0 or ~> 0.4", targets: @all_targets},
      {:kino, "~> 0.7"},
      {:kino_maplibre, "~> 0.1.0"},
      {:kino_vega_lite, "~> 0.1.1"},
      {:maplibre, "~> 0.1.0"},
      {:nerves_key, "~> 1.0", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},
      {:nerves_time_zones, "~> 0.3.0", targets: @all_targets},
      {:nx, "~> 0.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:pinout, "~> 0.1"},
      {:progress_bar, "~> 3.0"},
      {:ramoops_logger, "~> 0.1", targets: @all_targets},
      {:recon, "~> 2.5"},
      {:req, "~> 0.3.0"},
      {:stb_image, "~> 0.6.0"},
      {:vega_lite, "~> 0.1"},
      {:rustler, "0.29.1"},

      {:mqscope, path: "/home/chantepierre/mqscope", runtime: false, nerves: [compile: true], targets: :mqscope},


      # Compile-time only
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.3", only: :dev, runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:sbom, "~> 0.6", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      assets: "assets",
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  def release do
    [
      overwrite: true,
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: [keep: ["Docs"]]
    ]
  end

  defp dialyzer() do
    [
      flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs],
      ignore_warnings: ".dialyzer_ignore.exs"
    ]
  end
end
