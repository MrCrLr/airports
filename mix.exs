defmodule Airports.MixProject do
  use Mix.Project

  def project do
    [
      app: :airports,
      version: "0.0.1",
      name: "Airports",
      escript: escript_config(),
      elixir: "~> 1.19",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :xmerl]]
  end

  defp deps do
    [
      {:req, "~> 0.5.16"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:earmark, "~> 1.4.47", only: :dev, runtime: false},
      {:stream_data, "~> 1.2", only: :test},
      {:excoveralls, "~> 0.18", only: :test}
      # optionally: {:castore, "~> 1.0", only: [:dev, :test]}
    ]
  end

  defp escript_config do
    [main_module: Airports, emu_args: "+Bd"]
  end
end
