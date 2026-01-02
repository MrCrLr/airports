defmodule Airports.Forecasts.ForecastsTest do
  use ExUnit.Case, async: true

  alias Airports.Forecasts.Forecasts

  test "fetch returns ok tuple on 200" do
    [res] = Forecasts.fetch("KJFK")
    assert {:ok, %{airport: "KJFK", body: body}} = res
    assert body =~ "<current_observation>"
  end

  import ExUnit.CaptureLog

  test "fetch returns http_error tuple on non-200" do
    capture_log(fn ->
      Process.put({Airports.HttpStub, :mode}, :http_404)
      [res] = Forecasts.fetch("KJFK")
      assert {:error, %{airport: "KJFK", reason: {:http_error, 404}}} = res
    end)
  end

  test "fetch returns transport error tuple" do
    capture_log(fn ->
      Process.put({Airports.HttpStub, :mode}, :error)
      [res] = Forecasts.fetch("KJFK")
      assert {:error, %{airport: "KJFK", reason: :boom}} = res
    end)
  end
end

