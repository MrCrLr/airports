defmodule AirportsTest do
  use ExUnit.Case, async: true

  test "Airports exposes main/1 as the public entrypoint" do
    assert {:module, Airports} = Code.ensure_loaded(Airports)
    assert function_exported?(Airports, :main, 1)
  end
end

