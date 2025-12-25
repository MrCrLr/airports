defmodule Airports.MixProject do

  use Mix.Project

  def project do
    [
      app:             :airports,
      version:         "0.0.1",
      name:            "Airports",
      escript:         escript_config(),
      elixir:          "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps:            deps()
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
      { :req,     "~> 0.5.16" },
      { :ex_doc,  "~> 0.34"   },
      { :earmark, "~> 1.4.47" }
    ]
  end

  defp escript_config do
    [
      main_module: Airports.CLI
    ]
  end

end
