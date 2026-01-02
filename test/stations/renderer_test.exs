defmodule Airports.Stations.RendererTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Airports.Stations.{Renderer, Station}

  test "render([]) prints no stations" do
    out = capture_io(fn -> assert Renderer.render([]) == :ok end)
    assert out =~ "No stations found."
  end

  test "render station struct prints id/name/state/coords" do
    s = %Station{id: "KBOS", name: "Logan", state: "MA", latitude: 1.0, longitude: 2.0}
    out = capture_io(fn -> assert Renderer.render([s]) == :ok end)

    assert out =~ "KBOS - Logan"
    assert out =~ "State: MA"
    assert out =~ "Coordinates: 1.0, 2.0"
  end

  test "render station prints unknown coords when nil" do
    s = %Station{id: "KBOS", name: "Logan", state: "MA", latitude: nil, longitude: nil}
    out = capture_io(fn -> Renderer.render([s]) end)
    assert out =~ "Coordinates: unknown"
  end

  test "render menu items prints numbered lines" do
    out = capture_io(fn -> Renderer.render([{"KBOS - Logan (0 km)", 1}]) end)
    assert out =~ "1. KBOS - Logan (0 km)"
  end
end

