defmodule Airports.Stations.Search do
  alias Airports.Stations.{Index, Fuzzy, Proximity, Selection}

  #
  # Public API (used by App / CLI)
  #
  def search(query, opts \\ []) do
    stations = Index.all()
    search(query, stations, opts)
  end

  #
  # Core search logic (pure, test-driven)
  #
  def search(query, stations, opts) do
    with {:ok, anchor} <- Fuzzy.resolve_anchor(query, stations),
         candidates <- Proximity.expand(anchor, stations, opts),
         ranked <- rank(anchor, candidates) do
      Selection.choose(ranked)
    end
  end

  #
  # Ranking: anchor first, then nearest
  #
  defp rank(anchor, stations) do
    Enum.sort_by(stations, fn {station, distance} ->
      {
        station.id != anchor.id,
        distance
      }
    end)
  end
end
