defmodule Mix.Tasks.Airports.Cities.Build do
  use Mix.Task

  @shortdoc "Build a US/CA-only derived cities TSV from a GeoNames dump"

  @allowed MapSet.new(~w(US CA))

  def run(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [in: :string, out: :string, min_population: :integer],
        aliases: [i: :in, o: :out, p: :min_population]
      )

    in_path = opts[:in] || raise "missing --in <path>"
    out_path = opts[:out] || raise "missing --out <path>"
    min_pop = opts[:min_population] || 500

    File.mkdir_p!(Path.dirname(out_path))

    in_path
    |> File.stream!([], :line)
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.reject(&(&1 == ""))
    |> Stream.map(&parse_raw/1)
    |> Stream.reject(&is_nil/1)
    |> Stream.filter(fn {_id, _name, _ascii, _lat, _lon, _country, _admin1, _admin2, pop, _fcode} ->
      pop >= min_pop
    end)
    |> Stream.map(&to_derived_tsv/1)
    |> Stream.into(File.stream!(out_path, [:write]))
    |> Stream.run()

    Mix.shell().info("Wrote: #{out_path}")
  end

  # raw GeoNames 19-col row -> derived tuple
  defp parse_raw(line) do
    case :binary.split(line, "\t", [:global]) do
      [id, name, asciiname, _alts, lat, lon, fclass, fcode, country, _cc2,
       admin1, admin2, _admin3, _admin4, pop, _elev, _dem, _tz, _mod] ->
        cond do
          fclass != "P" -> nil
          not MapSet.member?(@allowed, country) -> nil
          true ->
            {id, name, asciiname, lat, lon, country, admin1, admin2, to_int(pop), fcode}
        end

      _ ->
        nil
    end
  end

  defp to_derived_tsv({id, name, asciiname, lat, lon, country, admin1, admin2, pop, fcode}) do
    [
      id, "\t", name, "\t", asciiname, "\t",
      lat, "\t", lon, "\t", country, "\t",
      admin1, "\t", admin2, "\t", Integer.to_string(pop), "\t", fcode, "\n"
    ]
  end

  defp to_int(<<>>), do: 0
  defp to_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end

end

