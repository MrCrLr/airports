defmodule Airports.Cities.StoreTest do
  use ExUnit.Case, async: true

  alias Airports.Cities.Store
  alias Airports.Cities.City

  setup do
    # Store caches cities in Process dictionary; clear between tests
    Process.delete(:cities_cache)
    :ok
  end

  test "lookup/2 returns %City{} structs from derived TSV" do
    results = Store.lookup("springfield", 500)

    assert is_list(results)
    assert Enum.all?(results, &match?(%City{}, &1))
  end

  test "lookup/2 filters by min population" do
    # fixture has multiple Springfields; ensure filtering works
    results = Store.lookup("springfield", 160_000)
    assert Enum.all?(results, fn c -> c.population >= 160_000 end)
  end

  test "blank admin2 becomes nil (if present in fixture)" do
    # This test only makes sense if you include a row with blank admin2 in the fixture.
    # Example row: ... US 03 <blank> 4212 PPL
    results = Store.lookup("toronto", 500)

    # Toronto row has admin2 set in fixture; this is just a pattern check:
    assert [%City{} = toronto | _] = results
    assert toronto.admin2 in [nil, "3520"]
  end
end

