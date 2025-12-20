defmodule Airports.CLI do

  @moduledoc """
  Handle the command line parsing and the dispatch to
  various functions that end up generating a table of 
  the current weather conditions at the given airports.
  """

  def run(argv) do
    argv
    |> parse_argv
    |> process
    |> render()
  end

  defp process({:ok, airports}) do
    airports
    |> Airports.Forecasts.fetch()
    |> Enum.map(&parse_forecast/1)
  end

  defp process(:help) do
    IO.puts """
    usage: airports <airport_code> [ <more_airport_codes> ]
    """
    System.halt(0)
  end

  defp process({:error, reason}) do
    IO.puts "error: #{inspect(reason)}"
    System.halt(1)
  end

  defp parse_forecast({:ok, %{airport: airport, body: xml}}) do
    case Airports.ForecastParser.parse(xml) do
      {:ok, %Airports.Forecast{} = forecast} ->
        {:ok, forecast}

      {:error, reason} ->
        {:error, %{airport: airport, reason: reason}}
    end
  end

  defp render(results) do
    Enum.each(results, &render_result/1)
  end

  defp render_result({:ok, %Airports.Forecast{} = forecast}) do
    IO.puts("")
    IO.puts("Airport: #{forecast.station_id}")
    IO.puts("Location: #{forecast.location}")
    IO.puts("Observed: #{forecast.observation_time}")
    IO.puts("Weather: #{forecast.weather}")
    IO.puts("Temperature: #{forecast.temperature_string}")

    if forecast.wind_string do
      IO.puts("Wind: #{forecast.wind_string}")
    end

    if forecast.visibility_mi do
      IO.puts("Visibility: #{forecast.visibility_mi} mi")
    end
  end

  defp render_result({:error, error_data}) do
    handle_error(error_data)
  end

  defp handle_error(%{airport: airport, reason: {:http_error, status}}) do
    IO.puts "HTTP #{status} fetching weather from #{airport}"
    nil
  end

  defp handle_error(%{airport: airport, reason: reason}) do
    IO.puts "Error fetching weather for #{airport}: #{inspect(reason)}"
    nil
  end

  @doc """
  Parses command-line arguments.

  Returns:
    * :help when -h or --help is passed
    * {:ok, [airport_code, ...]} for one more ICAO codes
    * {:error, :invlaid_arguments} otherwise
  """
  def parse_argv(argv) do
    OptionParser.parse(
      argv, 
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> argv_to_internal
  end

  defp argv_to_internal({opts, args, _invalid}) when is_list(opts) do
    if Keyword.get(opts, :help, false) do
      :help
    else
      args_to_internal_representation(args)
    end
  end

  defp args_to_internal_representation([]) do
    {:error, :invalid_arguments}
  end

  defp args_to_internal_representation(codes) do
    {:ok, normalize_codes(codes)}
  end

  defp normalize_codes(codes) do
    codes
    |> Enum.map(&String.upcase/1)
  end
end

