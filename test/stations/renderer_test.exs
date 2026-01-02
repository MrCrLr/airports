defmodule Airports.Stations.RendererTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Airports.Stations.Station
  alias Airports.Stations.Renderer

  test "renders stations without crashing" do
    stations = [
      %Station{id: "CYYC", name: "Calgary", state: "AB"}
    ]

    output =
      capture_io(fn ->
        assert :ok = Renderer.render(stations)
      end)

    # Optional: assert something meaningful about the output
    assert output =~ "CYYC"
    assert output =~ "Calgary"
  end
end

