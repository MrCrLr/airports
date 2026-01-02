defmodule Airports.CLIPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData

  # Tokens that would trigger help behavior
  @help_flags ["-h", "--help"]

  defp token() do
    string(:printable, min_length: 1, max_length: 12)
  end

  defp safe_word() do
    # Avoid words that look like options (start with "-"), so OptionParser doesn't eat them.
    string(:alphanumeric, min_length: 1, max_length: 12)
    |> filter(fn s -> not String.starts_with?(s, "-") end)
  end

  defp code_token() do
    # "airport code-ish" tokens; also avoid reserved CLI commands exactly.
    string(:alphanumeric, min_length: 1, max_length: 8)
    |> filter(fn s -> s not in ["search", "list", "-h", "--help"] end)
  end

  property "help flag anywhere returns :help" do
    check all prefix <- list_of(token(), max_length: 6),
              suffix <- list_of(token(), max_length: 6),
              flag <- member_of(@help_flags) do
      argv = prefix ++ [flag] ++ suffix
      assert Airports.CLI.parse_argv(argv) == :help
    end
  end

  property "non-empty list of codes is uppercased" do
    check all codes <- list_of(code_token(), min_length: 1, max_length: 8) do
      assert Airports.CLI.parse_argv(codes) ==
               {:ok, Enum.map(codes, &String.upcase/1)}
    end
  end

  property "search joins query words with spaces when no options are present" do
    check all words <- list_of(safe_word(), min_length: 1, max_length: 6) do
      argv = ["search" | words]

      assert Airports.CLI.parse_argv(argv) ==
               {:stations, {:search, Enum.join(words, " "), []}}
    end
  end

  property "search --radius N maps to [radius_km: N] for positive N" do
    check all words <- list_of(safe_word(), min_length: 1, max_length: 6),
              r <- integer(1..10_000) do
      argv = ["search" | words] ++ ["--radius", Integer.to_string(r)]

      assert Airports.CLI.parse_argv(argv) ==
               {:stations, {:search, Enum.join(words, " "), [radius_km: r]}}
    end
  end

  property "search --radius N errors for N <= 0" do
    check all words <- list_of(safe_word(), min_length: 1, max_length: 6),
              r <- integer(-1000..0) do
      argv = ["search" | words] ++ ["--radius", Integer.to_string(r)]

      assert {:error, msg} = Airports.CLI.parse_argv(argv)
      assert msg =~ "radius must be a positive integer"
    end
  end
end

