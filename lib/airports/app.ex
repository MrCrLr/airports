defmodule Airports.App do
  require Logger

  alias Airports.Forecasts
  alias Airports.Stations
  alias Airports.Cities

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

    with cities when cities != [] 
         <- Cities.Search.search_candidates(query, min_population: 500),
         {:ok, city}     <- Cities.Selector.choose(cities),
         {:ok, ranked}   <- Stations.Search.within_radius(city, opts),
         {:ok, picked}   <- Stations.Selector.choose(ranked),
         {:ok, station}  <- normalize_station(picked) do
      Stations.Renderer.render([station])
    else
      [] -> IO.puts("No matching cities found.")
      {:error, :cancelled} -> :ok
      {:error, reason} ->
        Logger.error("Search failed: #{inspect(reason)}")
    end
  end

  defp normalize_station({%Stations.Station{} = station, _distance}), do: {:ok, station}
  defp normalize_station(%Stations.Station{} = station), do: {:ok, station}
  defp normalize_station(other), do: {:error, {:unexpected_selection, other}}

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
