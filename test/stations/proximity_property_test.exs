defmodule Airports.Stations.ProximityPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData
  alias Airports.Stations.Proximity

  # shrink-friendly "float-ish" coords
  defp latitude do
    integer(-90_000..90_000) |> map(&(&1 / 1000))
  end

  defp longitude do
    integer(-180_000..180_000) |> map(&(&1 / 1000))
  end

  defp coord do
    bind(latitude(), fn lat ->
      map(longitude(), fn lon -> {lat, lon} end)
    end)
  end

  defp station do
    bind(coord(), fn {lat, lon} ->
      # Proximity only needs latitude/longitude fields
      constant(%{latitude: lat, longitude: lon})
    end)
  end

  property "all returned distances are <= radius and non-negative" do
    check all {alat, alon} <- coord(),
              stations <- list_of(station(), max_length: 80),
              radius <- integer(0..50_000) do
      anchor = %{latitude: alat, longitude: alon}

      results = Proximity.expand(anchor, stations, radius_km: radius)

      Enum.each(results, fn {_station, dist} ->
        assert is_number(dist)
        assert dist >= 0.0
        assert dist <= radius + 1.0e-9
      end)
    end
  end

  property "default radius is equivalent to explicitly passing radius_km: 50" do
    check all {alat, alon} <- coord(),
              stations <- list_of(station(), max_length: 80) do
      anchor = %{latitude: alat, longitude: alon}

      assert Proximity.expand(anchor, stations) ==
               Proximity.expand(anchor, stations, radius_km: 50)
    end
  end

  property "very large radius includes all stations (distance on Earth max ~20037km)" do
    check all {alat, alon} <- coord(),
              stations <- list_of(station(), max_length: 80) do
      anchor = %{latitude: alat, longitude: alon}

      results = Proximity.expand(anchor, stations, radius_km: 25_000)

      assert length(results) == length(stations)
    end
  end
end

