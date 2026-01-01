defmodule Airports.Stations.Selector do
  alias Airports.Stations.Station
  alias Airports.UI.Menu

  def choose([]), do: {:error, :no_results}

  def choose([{station, _distance}]), do: {:ok, station}

  def choose(results) do
    items = 
      Enum.map(results, fn {station, distance} ->
        {format(station, distance), station}
      end)

    Menu.select("Select a station:", items)
  end

  defp format(%Station{} = station, distance) do
    "#{station.id} - #{station.name} (#{round(distance)} km)"
  end
end
