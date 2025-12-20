defmodule Airports.CLITest do
  use ExUnit.Case, async: true

  alias Airports.CLI

  describe "parse_argv/1" do
    test "returns :help when -h is passed" do
      assert CLI.parse_argv(["-h"]) == :help
    end

    test "returns :help when --help is passed" do
      assert CLI.parse_argv(["--help"]) == :help
    end

    test "returns :help when help flag comes after an airport code" do
      assert CLI.parse_argv(["k6b9", "-h"]) == :help
    end

    test "returns {:ok, [code]} for a single airport code" do
      assert CLI.parse_argv(["k6b9"]) == {:ok, ["K6B9"]}
    end

    test "returns {:ok, [codes]} for multiple airport codes" do
      assert CLI.parse_argv(["k6b9", "egll", "kjfk"]) ==
               {:ok, ["K6B9", "EGLL", "KJFK"]}
    end

    test "returns error when no arguments are given" do
      assert CLI.parse_argv([]) == {:error, :invalid_arguments}
    end
  end
end
