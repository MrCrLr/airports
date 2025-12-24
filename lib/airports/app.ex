defmodule Airports.App do

  alias Airports.Forecasts
  alias Airports.Stations

  def run(airports) when is_list(airports) do
    airports
    |> Forecasts.Forecasts.fetch()
    |> Enum.map(&parse_forecast/1)
    |> Forecasts.Renderer.render()
  end

  def run({:stations, :list}) do
    with {:ok, xml} <- Stations.Index.fetch(),
         {:ok, stations} <- Stations.IndexParser.parse(xml) do
      Stations.Renderer.render(stations)
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
