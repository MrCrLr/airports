defmodule Airports.Stations.Proximity do
  alias Airports.Geo

  @default_radius_km 50

  def expand(anchor, stations, opts \\ []) do
    radius = Keyword.get(opts, :radius_km, @default_radius_km)

    Enum.flat_map(stations, fn station ->
      distance =
        Geo.distance_km(
          {anchor.latitude, anchor.longitude},
          {station.latitude, station.longitude}
        )

      if distance <= radius do
        [{station, distance}]
      else
        []
      end
    end)
  end
end
