defmodule Airports.Stations.Search do
  alias Airports.Stations.{Index, Proximity}

  @index Application.compile_env(:airports, :stations_index, Index)

  def within_radius(anchor, opts \\ []) do
    with {:ok, stations} <- @index.all() do
      ranked =
        anchor
        |> Proximity.expand(stations, opts)
        |> Enum.sort_by(fn {_station, distance_km} -> distance_km end)

      {:ok, ranked}
    end
  end
end

