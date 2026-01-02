defmodule Airports.Forecasts.RendererTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Airports.Forecasts.{Renderer, Forecast}

  test "renders ok forecast including wind and visibility when present" do
    f = %Forecast{
      location: "Somewhere",
      station_id: "KBOS",
      observation_time: "Now",
      weather: "Fair",
      temperature_string: "10C",
      wind_string: "Calm",
      visibility_mi: "8.00"
    }

    out = capture_io(fn -> Renderer.render([{:ok, f}]) end)

    assert out =~ "Location: Somewhere"
    assert out =~ "ICAO Code:   KBOS"
    assert out =~ "Wind:"
    assert out =~ "Visibility:"
  end

  test "renders ok forecast without wind/visibility when nil" do
    f = %Forecast{
      location: "Somewhere",
      station_id: "KBOS",
      observation_time: "Now",
      weather: "Fair",
      temperature_string: "10C",
      wind_string: nil,
      visibility_mi: nil
    }

    out = capture_io(fn -> Renderer.render([{:ok, f}]) end)

    refute out =~ "Wind:"
    refute out =~ "Visibility:"
  end

  test "renders error result" do
    out = capture_io(fn -> Renderer.render([{:error, %{airport: "KBOS", reason: :boom}}]) end)
    assert out =~ "Error for KBOS"
    assert out =~ ":boom"
  end
end
