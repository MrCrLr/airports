defmodule Airports.Stations.IndexTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.Index

  test "fetch returns XML" do
    assert {:ok, body} = Index.fetch()
    assert is_binary(body)
    assert String.contains?(body, "<wx_station_index>")
  end
end
