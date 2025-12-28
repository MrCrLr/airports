defmodule Airports.Stations.Fuzzer do
  alias Airports.Stations.{Index, Fuzzy, Proximity}

  def search(query, opts \\ []) do
    stations = Index.all()
    search(query, stations, opts)
  end

  def search(query, stations, opts) do
    with {:ok, anchor} <- Fuzzy.resolve_anchor(query, stations) do
      candidates = Proximity.expand(anchor, stations, opts)
      ranked = rank(anchor, candidates)
      {:ok, ranked}
    end
  end

  defp rank(anchor, stations) do
    Enum.sort_by(stations, fn {station, distance} ->
      {station.id != anchor.id, distance}
    end)
  end

end
