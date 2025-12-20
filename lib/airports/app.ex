defmodule Airports.App do
  alias Airports.{Forecasts, ForecastParser, Renderer, Forecast}

  def run(airports) when is_list(airports) do
    airports
    |> Forecasts.fetch()
    |> Enum.map(&parse_forecast/1)
    |> Renderer.render()
  end

  defp parse_forecast({:ok, %{airport: airport, body: xml}}) do
    case ForecastParser.parse(xml) do
      {:ok, %Forecast{} = forecast} ->
        {:ok, forecast}

      {:error, reason} ->
        {:error, %{airport: airport, reason: reason}}
    end
  end

  defp parse_forecast({:error, error}) do
    {:error, error}
  end
end
