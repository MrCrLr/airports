defmodule Airports.MixProject do

  use Mix.Project

  def project do
    [
      app:               :airports,
      version:           "0.0.1",
      name:              "Airports",
      escript:           escript_config(),
      elixir:            "~> 1.19",
      build_embedded:    Mix.env() == :prod,
      start_permanent:   Mix.env() == :prod,
      test_coverage:     [tool: ExCoveralls],
      deps:              deps()
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls:             :test,
        "coveralls.detail":    :test,
        "coveralls.post":      :test,
        "coveralls.html":      :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :req,         "~> 0.5.16" },
      { :ex_doc,      "~> 0.34"   },
      { :earmark,     "~> 1.4.47" },
      { :stream_data, "~> 1.2", only: :test },
      {:excoveralls, "~> 0.18", only: :test }
    ]
  end

  defp escript_config do
    [
      main_module: Airports,
      emu_args: "+Bd"
    ]
  end

end
