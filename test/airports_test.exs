defmodule AirportsTest do
  use ExUnit.Case, async: true

  test "Airports exposes main/1 as the public entrypoint" do
    assert Code.ensure_loaded?(Airports)
    assert {:main, 1} in Airports.__info__(:functions)
  end
end

