defmodule Airports.App do
  require Logger

  alias Airports.Forecasts
  alias Airports.Stations

  def run(airports) when is_list(airports) do
    Logger.info("Fetching forecasts for #{length(airports)} airports")

    airports
    |> Forecasts.Forecasts.fetch()
    |> Enum.map(&parse_forecast/1)
    |> Forecasts.Renderer.render()
  end

  def run({:stations, :list}) do
    Logger.info("Listing all stations")

    with {:ok, xml} <- Stations.Index.fetch(),
         {:ok, stations} <- Stations.IndexParser.parse(xml) do
      Logger.info("Parsed #{length(stations)} stations")
      Stations.Renderer.render(stations)
    end
  end

  def run({:stations, {:search, query, opts}}) do
    Logger.info("Running station search")

    case Airports.Stations.Search.search(query, opts) do
      {:ok, results} ->
        Airports.Stations.Renderer.render(results)

      {:error, :no_match} ->
        IO.puts("No matching stations found.")
    end
  end

  defp parse_forecast({:ok, %{airport: airport, body: xml}}) do
    case Forecasts.Parser.parse(xml) do
      {:ok, %Forecasts.Forecast{} = forecast} ->
        {:ok, forecast}

      {:error, reason} ->
        {:error, %{airport: airport, reason: reason}}
    end
  end

  defp parse_forecast({:error, error}) do
    {:error, error}
  end
end
