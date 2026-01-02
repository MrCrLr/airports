defmodule Airports.Stations.ProximityMorePropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData

  alias Airports.Stations.Proximity
  alias Airports.Geo

  # shrink-friendly coord generators
  defp latitude, do: integer(-90_000..90_000) |> map(&(&1 / 1000))
  defp longitude, do: integer(-180_000..180_000) |> map(&(&1 / 1000))

  defp coord do
    bind(latitude(), fn lat ->
      map(longitude(), fn lon -> {lat, lon} end)
    end)
  end

  defp anchor do
    map(coord(), fn {lat, lon} -> %{latitude: lat, longitude: lon} end)
  end

  defp station do
    bind(coord(), fn {lat, lon} ->
      # include an id so we can compare station identity in sets
      map(integer(0..1_000_000), fn id ->
        %{id: id, latitude: lat, longitude: lon}
      end)
    end)
  end

  defp station_list do
    list_of(station(), max_length: 80)
  end

  property "results are exactly the input stations that satisfy distance <= radius, preserving order" do
    check all a <- anchor(),
              stations <- station_list(),
              radius <- integer(0..50_000) do
      expected =
        Enum.flat_map(stations, fn s ->
          d = Geo.distance_km({a.latitude, a.longitude}, {s.latitude, s.longitude})
          if d <= radius, do: [{s, d}], else: []
        end)

      assert Proximity.expand(a, stations, radius_km: radius) == expected
    end
  end

  property "increasing radius is monotonic: results at r1 are a subset of results at r2 (by station id)" do
    check all a <- anchor(),
              stations <- station_list(),
              r1 <- integer(0..25_000),
              r2_delta <- integer(0..25_000) do
      r2 = r1 + r2_delta

      res1 = Proximity.expand(a, stations, radius_km: r1) |> Enum.map(fn {s, _d} -> s.id end) |> MapSet.new()
      res2 = Proximity.expand(a, stations, radius_km: r2) |> Enum.map(fn {s, _d} -> s.id end) |> MapSet.new()

      assert MapSet.subset?(res1, res2)
    end
  end

  property "permuting the input stations does not change which stations qualify (as a set)" do
    check all a <- anchor(),
              stations <- station_list(),
              radius <- integer(0..50_000) do
      # shuffle/1 is fine here; we only compare sets of ids
      shuffled = Enum.shuffle(stations)

      ids1 =
        Proximity.expand(a, stations, radius_km: radius)
        |> Enum.map(fn {s, _d} -> s.id end)
        |> MapSet.new()

      ids2 =
        Proximity.expand(a, shuffled, radius_km: radius)
        |> Enum.map(fn {s, _d} -> s.id end)
        |> MapSet.new()

      assert ids1 == ids2
    end
  end

  property "radius 0 returns only stations with identical coordinates (distance 0)" do
    check all a <- anchor(),
              stations <- station_list() do
      res = Proximity.expand(a, stations, radius_km: 0)

      Enum.each(res, fn {s, d} ->
        assert d == 0.0
        assert s.latitude == a.latitude
        assert s.longitude == a.longitude
      end)
    end
  end
end

