defmodule Airports.ForecastParserTest do
  use ExUnit.Case, async: true

  test "extracts station_id from XML" do
    xml = """
    <current_observation>
      <station_id>K6B9</station_id>
    </current_observation>
    """

    assert Airports.ForecastParser.parse(xml) ==
             {:ok, %{station_id: "K6B9"}}
  end
end
