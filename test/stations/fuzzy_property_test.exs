defmodule Airports.Stations.FuzzyPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData

  alias Airports.Stations.Fuzzy
  alias Airports.Stations.Station

  # Generate a lowercase a-z token as a binary string.
  defp letters(min, max) do
    list_of(member_of(Enum.map(?a..?z, &<<&1>>)), min_length: min, max_length: max)
    |> map(&Enum.join/1)
  end

  defp station_name_containing(token) do
    # Add punctuation + casing noise that normalize/1 should ignore.
    member_of([
      "  #{String.upcase(token)}-International Airport  ",
      "#{String.capitalize(token)}, regional airfield!",
      "#{token} field",
      "the #{token} station"
    ])
  end

  defp station_name_not_containing(token) do
    # Build random names and filter out ones that accidentally contain the token.
    list_of(letters(3, 10), min_length: 1, max_length: 4)
    |> map(&Enum.join(&1, " "))
    |> filter(fn name ->
      # Fuzzy.normalize/1 is private; this is good enough for ensuring "not an exact contains"
      not String.contains?(String.downcase(name), token)
    end)
  end

  property "empty station list returns {:error, :no_match}" do
    check all query <- string(:printable, min_length: 0, max_length: 20) do
      assert Fuzzy.resolve_anchor(query, []) == {:error, :no_match}
    end
  end

  property "an exact match is found even with case/punctuation differences" do
    check all token <- letters(3, 10),
              name <- station_name_containing(token) do
      station = %Station{id: "EXACT", name: name}

      # Query is also noisy; normalize/1 should handle it
      query = "!! #{String.upcase(token)} ??"

      assert Fuzzy.resolve_anchor(query, [station]) == {:ok, station}
    end
  end

  property "when an exact match exists, it returns the first exact match in list order" do
    check all token <- letters(3, 10),
              prefix <- list_of(station_name_not_containing(token), max_length: 6),
              suffix <- list_of(station_name_not_containing(token), max_length: 6),
              exact_name <- station_name_containing(token) do
      prefix_stations =
        Enum.with_index(prefix, fn name, i ->
          %Station{id: "P#{i}", name: name}
        end)

      exact_station = %Station{id: "EXACT", name: exact_name}

      suffix_stations =
        Enum.with_index(suffix, fn name, i ->
          %Station{id: "S#{i}", name: name}
        end)

      stations = prefix_stations ++ [exact_station] ++ suffix_stations

      assert Fuzzy.resolve_anchor(token, stations) == {:ok, exact_station}
    end
  end
end

