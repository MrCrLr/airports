defmodule Airports.Forecasts.ParserTest do
  use ExUnit.Case, async: true

  alias Airports.Forecasts.Forecast
  alias Airports.Forecasts.Parser

  defp valid_xml do
    """
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <current_observation>
      <location>Test Location</location>
      <station_id>K6B9</station_id>
      <weather>Clear</weather>
      <observation_time>Now</observation_time>
      <temperature_string>70 F</temperature_string>
      <wind_string>Calm</wind_string>
    </current_observation>
    """
  end

  defp xml_without_location do
    """
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <current_observation>
      <station_id>K6B9</station_id>
      <weather>Clear</weather>
      <observation_time>Now</observation_time>
      <temperature_string>70 F</temperature_string>
      <wind_string>Calm</wind_string>
    </current_observation>
    """
  end

  defp xml_without_optional_fields, do: valid_xml()

  test "parses a valid forecast into a Forecast struct" do
    assert {:ok, %Forecast{} = forecast} =
             Parser.parse(valid_xml())

    assert forecast.station_id == "K6B9"
    assert forecast.location
    assert forecast.observation_time
    assert forecast.weather
    assert forecast.temperature_string
  end

  test "fails when location is missing" do
    xml = xml_without_location()
    assert {:error, {:missing_field, _}} =
             Parser.parse(xml)
  end

  test "missing optional fields do not fail parsing" do
    xml = xml_without_optional_fields()
    assert {:ok, forecast} = Parser.parse(xml)
    assert forecast.visibility_mi == nil
  end

end
