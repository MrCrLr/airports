defmodule Airports do
  @moduledoc """
  Public API for the Airports project.

  - CLI entrypoint lives in `Airports.CLI`
  - Domain functionality lives under `Airports.*` modules
  """

  @doc """
  CLI entrypoint.

  Delegates to `Airports.CLI.main/1` so `Airports.main/1` can be used as the
  app’s stable entrypoint (escript, releases, IEx).
  ## Examples
      iex(1)> Airports.__info__(:functions)
      [main: 1]
  """
  defdelegate main(argv), to: Airports.CLI
end

