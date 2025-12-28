defmodule Airports.CLI do
  @moduledoc """
  Command-line interface for the Airports application.

  This module is responsible for:
    * Parsing command-line arguments
    * Mapping user input into internal command representations
    * Dispatching execution to `Airports.App`

  The CLI supports two primary workflows:

    1. Fetching current weather observations for one or more airport ICAO codes
    2. Searching the NOAA station index using fuzzy name matching and geographic proximity

  All domain logic (searching, parsing, rendering) is delegated to lower layers.
  This module acts strictly as a boundary between user input and application logic.
  """

  require Logger
  alias Airports.App

  def main(argv), do: run(argv)

  def run(argv) do
    Logger.debug(fn -> "CLI argv: #{inspect(argv)}" end)

    case parse_argv(argv) do
      :help ->
        print_help()
        System.halt(0)

      {:ok, airports} ->
        App.run(airports)
        System.halt(0)

      {:stations, :list} ->
        App.run({:stations, :list})
        System.halt(0)

      {:stations, {:search, query, opts}} ->
        App.run({:stations, {:search, query, opts}})
        System.halt(0)

      {:error, msg} ->
        IO.puts(:stderr, "Error: #{msg}")
        IO.puts(:stderr, "\n" <> help_text())
        System.halt(1)
    end
  end

  @doc """
  Parses raw command-line arguments into an internal command representation.

  This function interprets user input and returns a normalized structure
  that can be consumed by `Airports.App.run/1`.

  This function does not execute any commands.

  ## Returns

    * `:help`
      When `-h` or `--help` is provided, or when no arguments are given.

    * `{:ok, [icao_code, ...]}`
      When one or more airport ICAO codes are provided.
      Codes are normalized to uppercase.

      Example:
          ["pamr", "kjfk"] -> {:ok, ["PAMR", "KJFK"]}

    * `{:stations, :list}`
      When the user requests a full station listing.

      Example:
          ["list"]

    * `{:stations, {:search, query, opts}}`
      When the user performs a station search.

      Example:
          ["search", "Boston", "--radius", "50"]

    * `{:error, :invalid_arguments}`
      When the arguments cannot be interpreted as a valid command.
  """

  def parse_argv([]), do: :help

  def parse_argv(argv) when is_list(argv) do
    if Enum.member?(argv, "-h") or Enum.member?(argv, "--help") do
      :help
    else
      do_parse(argv)
    end
  end

  def do_parse(["list"]) do 
    {:stations, :list}
  end

  def do_parse(["search" | rest]) do 
    parse_station_search(rest)
  end

  def do_parse(codes) do
    {:ok, Enum.map(codes, &String.upcase/1)}
  end

  defp parse_station_search(args) do
    {opts, rest, invalid} =
      OptionParser.parse(args,
        switches: [radius: :integer],
        aliases: [r: :radius]
      )

    cond do
      invalid != [] ->
        {:error, "invalid option(s): #{inspect(invalid)}"}

      rest == [] ->
        :help

      true ->
        query = Enum.join(rest, " ")

        normalize_radius_opts(opts)
        |> case do
          {:ok, norm_opts} -> {:stations, {:search, query, norm_opts}}
          {:error, msg} -> {:error, msg}
        end

    end
  end

  defp normalize_radius_opts(opts) do
    case Keyword.fetch(opts, :radius) do
      :error ->
        {:ok, []}  # Proximity module applies default @default_radius_km

      {:ok, r} when is_integer(r) and r > 0 ->
        {:ok, [radius_km: r]}

      {:ok, r} ->
        {:error, "radius must be a positive integer (got #{inspect(r)})"}
    end
  end

  defp print_help, do: IO.puts(help_text())

  defp help_text do
    """
    airports — query airport weather stations from NOAA

    USAGE
      airports <ICAO_CODE> [<MORE_CODES>...]

      airports search <QUERY> [options]
      airports list

    DESCRIPTION
      Fetches and displays current weather observations for NOAA weather stations,
      or helps you search for nearby weather stations by name or location.

    COMMANDS
      <ICAO_CODE> [<MORE_CODES>...]
          Fetch current observations for one or more airport ICAO codes.

          Example:
            airports PAMR KJFK

      search <QUERY>
          Search for a station by name (fuzzy matching supported),
          then return nearby stations sorted by distance.

          Examples:
            airports search Boston
            airports search Bostn
            airports search Boston --radius 50

          Options:
            --radius, -r <km>    Search radius in kilometers (default: 50)

      list
          List all available weather stations (advanced / debugging).

    OPTIONS
      -h, --help
          Show this help message.
    """
  end

end

