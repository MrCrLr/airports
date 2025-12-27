defmodule Airports.Stations.FuzzyTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.{Fuzzy, Station}

  @stations [
    %Station{id: "KBOS", name: "Boston, Logan International Airport", 
             state: "MA", latitude: 42.3656, longitude: -71.0096},
    %Station{id: "KJFK", name: "New York, Kennedy International Airport", 
             state: "NY", latitude: 40.6413, longitude: -73.7781},
    %Station{id: "KLAX", name: "Los Angeles, Los Angeles Internation Airport", 
             state: "CA", latitude: 33.9416, longitude: -118.4085}
  ]

  setup do
    {:ok, stations: @stations}
  end

  test "resolves exact station name match", %{stations: stations} do
    assert {:ok, %Station{name: name}} =
             Fuzzy.resolve_anchor("Boston", stations)
    assert String.contains?(name, "Boston")
  end

  test "resolves fuzzy station name match with typo", %{stations: stations} do
    assert {:ok, %Station{name: name}} =
             Fuzzy.resolve_anchor("Bostn", stations)
    assert String.contains?(name, "Boston")
  end

  test "is case insensitive", %{stations: stations} do
    assert {:ok, %Station{name: name}} =
             Fuzzy.resolve_anchor("bOsToN", stations)
    assert String.contains?(name, "Boston")
  end

  test "returns error when no reasonable match exists", %{stations: stations} do
    assert {:error, :no_match} =
             Fuzzy.resolve_anchor("Xylophone", stations)
  end
end
