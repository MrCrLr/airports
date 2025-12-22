defmodule Airports.StationRendererTest do
  use ExUnit.Case, async: true

  alias Airports.Station
  alias Airports.StationRenderer

  test "renders stations without crashing" do
    stations = [
      %Station{id: "CYYC", name: "Calgary", state: "AB"}
    ]

    assert :ok = StationRenderer.render(stations)
  end
end
