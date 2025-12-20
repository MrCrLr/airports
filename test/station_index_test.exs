defmodule Airports.StationIndexTest do
  use ExUnit.Case, async: true

  alias Airports.StationIndex

  test "fetch returns XML" do
    assert {:ok, body} = StationIndex.fetch()
    assert is_binary(body)
    assert String.contains?(body, "<wx_station_index>")
  end
end
