defmodule Airports.Cities.Store do
  @moduledoc false

  alias Airports.Text
  alias Airports.Cities.City

  @cities_path Application.compile_env!(:airports, :cities_path)
  @allowed_countries MapSet.new(~w(US CA))

  def lookup(query_key, min_pop) 
      when is_binary(query_key) and is_integer(min_pop) do
    if String.length(query_key) < 2 do
      []
    else
      cities()
      |> Enum.filter(fn %City{} = c ->
        c.population >= min_pop and
          (String.starts_with?(c.name_key, query_key) or 
           String.contains?(c.name_key, query_key))
      end)
      |> Enum.take(400)
    end
  end

  defp cities do
    case Process.get(:cities_cache) do
      nil ->
        cities =
          @cities_path
          |> File.stream!([], :line)
          |> Stream.map(&String.trim_trailing/1)
          |> Stream.reject(&(&1 == ""))
          |> Stream.map(&parse_row/1)
          |> Stream.reject(&is_nil/1)
          |> Enum.to_list()

        Process.put(:cities_cache, cities)
        cities

      cached ->
        cached
    end
  end

  # Accept raw GeoNames (19 cols) OR derived (10 cols)
  defp parse_row(line) do
    cols = :binary.split(line, "\t", [:global])

    case cols do
      # Derived TSV (recommended):
      # geonameid, name, asciiname, lat, lon, country, admin1, admin2, population, feature_code
      [id, name, asciiname, lat, lon, country, admin1, admin2, pop, fcode] ->
        build_city(id, name, asciiname, lat, lon, country, blank_to_nil(admin1), blank_to_nil(admin2), pop, fcode)

      # Raw GeoNames TSV (19 cols)
      [id, name, asciiname, _alts, lat, lon, fclass, fcode, country, _cc2,
       admin1, admin2, _admin3, _admin4, pop, _elev, _dem, _tz, _mod] ->
        cond do
          fclass != "P" -> nil
          not MapSet.member?(@allowed_countries, country) -> nil
          true -> build_city(id, name, asciiname, lat, lon, country, admin1, admin2, pop, fcode)
        end

      _ ->
        nil
    end
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(s), do: s

  defp build_city(id, name, asciiname, lat, lon, country, admin1, admin2, pop, fcode) do
    # If you feed it derived US/CA-only data, this is just extra safety:
    if MapSet.member?(@allowed_countries, country) do
      %City{
        geonameid: to_int(id),
        name: name,
        asciiname: asciiname,
        name_key: Text.normalize_key(asciiname),
        latitude: to_float(lat),
        longitude: to_float(lon),
        country: country,
        admin1: admin1,
        admin2: admin2,
        feature_code: fcode,
        population: to_int(pop)
      }
    end
  end

  defp to_int(<<>>), do: 0
  defp to_int(s) do
    case Integer.parse(s) do
      {n, _} -> n
      :error -> 0
    end
  end

  defp to_float(<<>>), do: 0.0
  defp to_float(s) do
    case Float.parse(s) do
      {n, _} -> n
      :error -> 0.0
    end
  end
end

