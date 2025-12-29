defmodule Airports.Stations.ProximityTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.Proximity

  defp station(lat, lon) do
    %{
      latitude: lat,
      longitude: lon,
      id: :dummy
    }
  end

  test "expand/3 filters stations by radius_km" do
    anchor = %{latitude: 40.0, longitude: -75.0}

    near = station(40.01, -75.01)
    far  = station(41.0, -75.0)

    results = Proximity.expand(anchor, [near, far], radius_km: 5)

    assert Enum.any?(results, fn {s, _d} -> s == near end)
    refute Enum.any?(results, fn {s, _d} -> s == far end)
  end

  test "expand/3 uses default radius when not provided" do
    anchor = %{latitude: 40.0, longitude: -75.0}
    far = station(40.4, -75.0) # ~44km-ish depending on lat

    results = Proximity.expand(anchor, [far], [])

    # default is 50km in your module, so this should be included
    assert length(results) == 1
  end
end

