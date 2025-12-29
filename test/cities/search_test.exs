defmodule Airports.Cities.SearchTest do
  use ExUnit.Case, async: true

  alias Airports.Cities.Search

  setup do
    Process.delete(:cities_cache)
    :ok
  end

  test "search_candidates/2 returns best matches first" do
    cities = Search.search_candidates("Springfield", min_population: 500, limit: 10)

    assert length(cities) > 1

    # Should all be Springfields (as a sanity check)
    assert Enum.all?(cities, fn c ->
      String.downcase(c.name) == "springfield" or String.downcase(c.asciiname) == "springfield"
    end)

    # Ranking should generally prefer larger population (your scoring nudges this)
    pops = Enum.map(cities, & &1.population)
    assert pops == Enum.sort(pops, :desc)
  end

  test "search_candidates/2 handles typos reasonably" do
    cities = Search.search_candidates("Sprngfield", min_population: 500, limit: 5)
    assert length(cities) >= 1
  end
end

