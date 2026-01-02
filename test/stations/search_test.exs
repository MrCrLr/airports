defmodule Airports.Stations.SearchTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.{Search, Station}

  test "within_radius returns ranked stations by distance" do
    anchor = %Station{id: "ANCHOR", latitude: 0.0, longitude: 0.0}
    {:ok, ranked} = Search.within_radius(anchor, radius_km: 50_000)

    assert Enum.map(ranked, fn {s, _d} -> s.id end) == ["A", "B"]
  end
end
