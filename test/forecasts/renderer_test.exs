defmodule Airports.Forecasts.RendererTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Airports.Forecasts.Forecast
  alias Airports.Forecasts.Renderer

  test "renders a forecast" do
    forecast =
      %Forecast{
        station_id: "PAMR",
        location: "Anchorage, Merrill Field Airport, AK",
        observation_time: "Some time",
        weather: "Fair",
        temperature_string: "-6.0 F (-21.1 C)"
      }

    output =
      capture_io(fn ->
        Renderer.render([{:ok, forecast}])
      end)

    assert output =~ "Airport: PAMR"
    assert output =~ "Weather: Fair"
    assert output =~ "-6.0 F"
  end
end
