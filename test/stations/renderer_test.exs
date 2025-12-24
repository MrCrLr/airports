defmodule Airports.Stations.RendererTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.Station
  alias Airports.Stations.Renderer

  test "renders stations without crashing" do
    stations = [
      %Station{id: "CYYC", name: "Calgary", state: "AB"}
    ]

    assert :ok = Renderer.render(stations)
  end
end
