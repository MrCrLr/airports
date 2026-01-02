defmodule Airports.SelectorsTest do
  use ExUnit.Case, async: true

  alias Airports.Cities.City
  alias Airports.Cities.Selector, as: CitySelector
  alias Airports.Stations.{Station, Selector}

  test "cities choose([]) errors" do
    assert CitySelector.choose([]) == {:error, :no_city_matches}
  end

  test "cities choose/1 calls menu with formatted labels" do
    c = %City{
      geonameid: 1,
      name: "Toronto",
      asciiname: "Toronto",
      name_key: "toronto",
      latitude: 43.6532,
      longitude: -79.3832,
      country: "CA",
      admin1: "08",
      admin2: nil,
      feature_code: "PPLA",
      population: 2_731_571
    }
    assert CitySelector.choose([c]) == {:ok, :stubbed}

    assert_received {:menu_select, "Select a city:", [{label, ^c}]}
    assert label =~ "Toronto, 08 CA"
    assert label =~ "pop"
  end

  test "cities selector omits pop suffix when population is nil" do
    c = %City{
      geonameid: 1,
      name: "X",
      asciiname: "X",
      name_key: "x",
      latitude: 0.0,
      longitude: 0.0,
      country: "US",
      admin1: "MA",
      population: nil
    }

    assert CitySelector.choose([c]) == {:ok, :stubbed}
    assert_received {:menu_select, _, [{label, ^c}]}
    refute label =~ "pop"
  end

  test "cities selector omits pop suffix when population is 0" do
    c = %City{
      geonameid: 2,
      name: "Y",
      asciiname: "Y",
      name_key: "y",
      latitude: 0.0,
      longitude: 0.0,
      country: "US",
      admin1: "MA",
      population: 0
    }

    assert CitySelector.choose([c]) == {:ok, :stubbed}
    assert_received {:menu_select, _, [{label, ^c}]}
    refute label =~ "pop"
  end

  test "stations choose([]) errors" do
    assert Selector.choose([]) == {:error, :no_results}
  end

  test "stations choose single tuple returns station directly" do
    s = %Station{id: "CYYZ"}
    assert Selector.choose([{s, 12.3}]) == {:ok, s}
  end

  test "stations choose many calls menu with distance formatting" do
    s1 = %Station{id: "CYYZ", name: "Pearson"}
    s2 = %Station{id: "CYUL", name: "Trudeau"}

    assert Selector.choose([{s1, 12.3}, {s2, 50.0}]) == {:ok, :stubbed}
    assert_received {:menu_select, "Select a station:", [{label1, ^s1}, {_label2, ^s2}]}
    assert label1 =~ "(12 km)"  # round(12.3)
  end
end
