defmodule Airports.Stations.IndexTest do
  use ExUnit.Case, async: true

  alias Airports.Stations.Index

  test "fetch returns body on 200" do
    assert {:ok, body} = Index.fetch()
    assert is_binary(body)
    assert_received {:http_get, url}
    assert url =~ "index.xml"
  end

  test "fetch returns http_error on non-200" do
    Process.put({Airports.HttpStub, :mode}, :http_404)
    assert {:error, {:http_error, 404}} = Index.fetch()
  end

  test "fetch returns {:error, reason} on transport error" do
    Process.put({Airports.HttpStub, :mode}, :error)
    assert {:error, :boom} = Index.fetch()
  end
end
