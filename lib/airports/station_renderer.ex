defmodule Airports.StationRenderer do
  alias Airports.Station

  def render([]) do
    IO.puts("No stations found.")
    :ok
  end

  def render(stations) when is_list(stations) do
    stations
    |> Enum.each(&render_station/1)

    :ok
  end

  defp render_station(%Station{} = station) do
    IO.puts("""
    #{station.id} - #{station.name}
      State: #{station.state}
      Coordinates: #{format_coords(station)}
    """)
  end

  defp format_coords(%Station{latitude: nil, longitude: nil}), do: "unknown"
  defp format_coords(%Station{latitude: lat, longitude: lon}), do: "#{lat}, #{lon}"

end

