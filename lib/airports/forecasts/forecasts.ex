defmodule Airports.Forecasts.Forecasts do
  require Logger

  @noaa_url Application.compile_env!(:airports, :noaa_url)

  def fetch(airport) when is_binary(airport) do
    fetch([airport])
  end

  def fetch(airports) when is_list(airports) do
    Enum.map(airports, &fetch_one/1)
  end

  defp fetch_one(airport) do
    Logger.debug(fn -> "Fetching forecast for #{airport}" end)

    airport
    |> forecast_url()
    |> Req.get()
    |> handle_response(airport)
  end

  defp handle_response({:ok, %{status: 200, body: body}}, airport) do
    Logger.debug(fn -> "Forecast fetch OK for #{airport}" end)

    {:ok, 
      %{
         airport: airport, 
         body: body
       }
    }
  end

  defp handle_response({:ok, %{status: status}}, airport) do
    Logger.warning(fn -> "HTTP #{status} fetching forecast for #{airport}" end)
    {:error, %{airport: airport, reason: {:http_error, status}}}
  end

  defp handle_response({:error, reason}, airport) do
    Logger.error(fn -> "HTTP error fetching #{airport}: #{inspect(reason)}" end)
    {:error, %{airport: airport, reason: reason}}
  end

  defp forecast_url(airport) do
    "#{@noaa_url}/#{airport}.xml"
  end
end
