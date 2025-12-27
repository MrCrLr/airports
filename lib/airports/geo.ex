defmodule Airports.Geo do
  @earth_radius_km 6371

  def distance_km({lat1, lon1}, {lat2, lon2}) do
    dlat = deg2rad(lat2 - lat1)
    dlon = deg2rad(lon2 - lon1)

    a =
      :math.sin(dlat / 2) ** 2 +
        :math.cos(deg2rad(lat1)) *
        :math.cos(deg2rad(lat2)) *
        :math.sin(dlon / 2) ** 2

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))
    @earth_radius_km * c
  end

  defp deg2rad(deg), do: deg * :math.pi() / 180
end
