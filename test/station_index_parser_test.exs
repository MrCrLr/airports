defmodule Airports.StationIndexParserTest do
  use ExUnit.Case, async: true

  alias Airports.StationIndexParser
  alias Airports.Station

  @valid_xml """
  <wx_station_index>
    <station>
      <station_id>CYYC</station_id>
      <state>AB</state>
      <station_name>Calgary International Airport</station_name>
      <latitude>51.11667</latitude>
      <longitude>-114.01667</longitude>
      <xml_url>https://example.com/CYYC.xml</xml_url>
      <html_url>https://example.com/CYYC.html</html_url>
      <rss_url>https://example.com/CYYC.rss</rss_url>
    </station>
  </wx_station_index>
  """

  test "parses station index into Station structs" do
    assert {:ok, [station]} = StationIndexParser.parse(@valid_xml)

    assert %Station{} = station
    assert station.id == "CYYC"
    assert station.name == "Calgary International Airport"
    assert station.state == "AB"
    assert station.latitude == 51.11667
    assert station.longitude == -114.01667
    assert station.xml_url == "https://example.com/CYYC.xml"
  end

  @missing_required_field_xml """
  <wx_station_index>
    <station>
      <state>AB</state>
      <station_name>Broken Station</station_name>
    </station>
  </wx_station_index>
  """

  test "stations missing required fields are dropped" do
    assert {:ok, stations} =
             StationIndexParser.parse(@missing_required_field_xml)

    assert stations == []
  end

  @mixed_xml """
  <wx_station_index>
    <station>
      <station_id>CYYC</station_id>
      <state>AB</state>
      <station_name>Calgary International Airport</station_name>
    </station>

    <station>
      <station_name>Broken Station</station_name>
    </station>
  </wx_station_index>
  """

  test "valid stations are returned even when others are invalid" do
    assert {:ok, [station]} =
             StationIndexParser.parse(@mixed_xml)

    assert station.id == "CYYC"
  end

  @missing_optional_fields_xml """
  <wx_station_index>
    <station>
      <station_id>CYYC</station_id>
      <state>AB</state>
      <station_name>Calgary International Airport</station_name>
    </station>
  </wx_station_index>
  """

  test "missing optional fields do not fail parsing" do
    assert {:ok, [station]} =
             StationIndexParser.parse(@missing_optional_fields_xml)

    assert station.latitude == nil
    assert station.longitude == nil
    assert station.xml_url == nil
  end

end

