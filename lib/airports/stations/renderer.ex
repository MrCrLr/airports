defmodule Airports.Stations.Renderer do

  alias Airports.Stations.Station

  def render([]) do
    IO.puts("No stations found.")
    :ok
  end

  def render([%Station{} | _] = stations) do
    Enum.each(stations, &render_station/1)
    :ok
  end

  def render([{line, idx} | _] = items) when is_binary(line) and is_integer(idx) do
    Enum.each(items, &render_station/1)
    :ok
  end

  defp render_station(%Station{} = station) do
    IO.puts("""
    #{station.id} - #{station.name}
      State: #{station.state}
      Coordinates: #{format_coords(station)}
    """)
  end

  defp render_station({line, idx}) when is_binary(line) and is_integer(idx) do
    IO.puts("#{idx}. #{line}")
  end

  defp format_coords(%Station{latitude: nil, longitude: nil}), do: "unknown"
  defp format_coords(%Station{latitude: lat, longitude: lon}), do: "#{lat}, #{lon}"

end
