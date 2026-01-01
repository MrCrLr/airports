defmodule Airports.Forecasts.Renderer do

  alias Airports.Forecasts.Forecast

  def render(results) when is_list(results) do
    Enum.each(results, &render_result/1)
  end

  defp render_result({:ok, %Forecast{} = forecast}) do
    IO.puts("""

    Location: #{forecast.location}
      ICAO Code:   #{forecast.station_id}
      Observed:    #{forecast.observation_time}
      Weather:     #{forecast.weather}
      Temperature: #{forecast.temperature_string}
    """)

    if forecast.wind_string, 
      do: IO.puts("  Wind:        #{forecast.wind_string}")

    if forecast.visibility_mi, 
      do: IO.puts("  Visibility:  #{forecast.visibility_mi} mi")
  end

  defp render_result({:error, %{airport: airport, reason: reason}}) do
    IO.puts("Error for #{airport}: #{inspect(reason)}")
  end

end

