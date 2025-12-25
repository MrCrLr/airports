defmodule Airports.CLI do
  require Logger

  alias Airports.App

  def main(argv), do: run(argv)

  def run(argv) do
    Logger.debug(fn -> "CLI argv: #{inspect(argv)}" end)

    case parse_argv(argv) do
      :help ->
        Logger.debug(fn -> "CLI help requested" end)
        print_help()
        System.halt(0)

      {:ok, airports} ->
        Logger.debug(fn -> "Running with airports: #{inspect(airports)}" end)
        App.run(airports)
        System.halt(0)

      {:stations, :list} ->
        Logger.debug(fn -> "CLI listing stations" end)
        App.run({:stations, :list})
        System.halt(0)
    end
  end

  defp print_help() do
    IO.puts("""
    Usage: 
      airports <airport_code> [ <more_airport_codes> ]

    Example:
      airports PAMR KJFK
    """)
  end

  @doc """
  Parses command-line arguments.

  Returns:
    * `:help` when `-h` or `--help` is passed
    * `{:ok, [airport_code, ...]}` for one more ICAO codes
    * `{:error, :invalid_arguments}` otherwise
  """

  def parse_argv(argv) do
    OptionParser.parse(
      argv, 
      switches: [help: :boolean],
      aliases:  [h:    :help]
    )
    |> argv_to_internal()
  end

  defp argv_to_internal({opts, args, _}) do
    if Keyword.get(opts, :help, false) do
      :help
    else
      args_to_internal_representation(args)
    end
  end

  defp args_to_internal_representation(["stations", "list"]) do
    {:stations, :list}
  end

  defp args_to_internal_representation([]) do 
    :help
  end

  defp args_to_internal_representation(codes) do
    {:ok, Enum.map(codes, &String.upcase/1)}
  end

end

