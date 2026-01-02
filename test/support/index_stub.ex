defmodule Airports.IndexStub do
  alias Airports.Stations.Station

  def all do
    {:ok,
     [
       %Station{id: "A", latitude: 0.0, longitude: 0.0},
       %Station{id: "B", latitude: 0.0, longitude: 0.1}
     ]}
  end
end
