defmodule Airports.CLITest do
  use ExUnit.Case, async: true

  alias Airports.CLI

  test "parse_argv empty => :help" do
    assert CLI.parse_argv([]) == :help
  end

  test "parse_argv -h/--help => :help" do
    assert CLI.parse_argv(["-h"]) == :help
    assert CLI.parse_argv(["--help"]) == :help
  end

  test "parse_argv ICAO codes => normalized uppercase list" do
    assert CLI.parse_argv(["kjfk", "KBOS", "Kdfw"]) == {:ok, ["KJFK", "KBOS", "KDFW"]}
  end

  test "parse_argv list => {:stations, :list}" do
    assert CLI.parse_argv(["list"]) == {:stations, :list}
  end

  test "parse_argv search query with radius" do
    assert CLI.parse_argv(["search", "Boston", "--radius", "50"]) ==
             {:stations, {:search, "Boston", [radius_km: 50]}}
  end

  test "parse_argv search query with -r alias" do
    assert CLI.parse_argv(["search", "Boston", "-r", "10"]) ==
             {:stations, {:search, "Boston", [radius_km: 10]}}
  end

  test "parse_argv search with no query => :help" do
    assert CLI.parse_argv(["search"]) == :help
  end

  test "parse_argv search invalid option value => {:error, msg}" do
    {:error, msg} = CLI.parse_argv(["search", "Boston", "--radius", "wat"])
    assert msg =~ "radius"
  end

  test "parse_argv search invalid radius => {:error, msg}" do
    {:error, msg} = CLI.parse_argv(["search", "Boston", "--radius", "-5"])
    assert msg =~ "radius must be a positive integer"
  end
end

