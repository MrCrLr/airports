defmodule Airports.Forecasts do

  @noaa_url Application.compile_env!(:airports, :noaa_url)

  def fetch(airport) when is_binary(airport) do
    fetch([airport])
  end

  def fetch(airports) when is_list(airports) do
    Enum.map(airports, &fetch_one/1)
  end

  defp fetch_one(airport) do
    airport
    |> forecast_url()
    |> Req.get()
    |> handle_response(airport)
  end

  defp handle_response({:ok, %{status: 200, body: body}}, airport) do
    {:ok, 
      %{
         airport: airport, 
         body: body
       }
    }
  end

  defp handle_response({:ok, %{status: status}}, airport) do
    {:error, %{airport: airport, reason: {:http_error, status}}}
  end

  defp handle_response({:error, reason}, airport) do
    {:error, %{airport: airport, reason: reason}}
  end

  defp forecast_url(airport) do
    "#{@noaa_url}/#{airport}.xml"
  end
end
