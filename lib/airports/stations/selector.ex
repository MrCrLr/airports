defmodule Airports.Stations.Selector do
  alias Airports.Stations.Station
  alias Airports.UI.Menu

  @menu Application.compile_env(:airports, :menu, Menu)

  def choose([]), do: {:error, :no_results}

  def choose([{station, _distance}]), do: {:ok, station}

  def choose(results) do
    items = 
      Enum.map(results, fn {station, distance} ->
        {format(station, distance), station}
      end)

    @menu.select("Select a station:", items)
  end

  defp format(%Station{} = station, distance) do
    "#{station.id} - #{station.name} (#{round(distance)} km)"
  end
end
