defmodule Airports.Cities.Search do
  alias Airports.Text
  alias Airports.Cities.{City, Store}

  @default_limit 10

  # Returns a list of candidate %City{} sorted best-first
  def search_candidates(query, opts \\ []) when is_binary(query) do
    min_pop = Keyword.get(opts, :min_population, 500)
    limit = Keyword.get(opts, :limit, @default_limit)

    query_key = Text.normalize_key(query)

    shortlist = fetch_shortlist(query_key, min_pop)

    shortlist =
      if shortlist == [] and byte_size(query_key) >= 3 do
        Store.lookup(String.slice(query_key, 0, 3), min_pop)
      else
        shortlist
      end

    shortlist
    |> Enum.map(&score(&1, query_key))
    |> Enum.sort_by(fn {score, %City{} = city} ->
      {-score, -feature_rank(city.feature_code), -(city.population || 0)}
    end)
    |> Enum.take(limit)
    |> Enum.map(fn {_score, city} -> city end)
  end

  defp score(%City{} = city, query_key) do
    # You already have a normalized key from Store (based on asciiname)
    ascii_key = city.name_key || Text.normalize_key(city.asciiname)
    name_key = Text.normalize_key(city.name)

    sim =
      max(
        String.jaro_distance(query_key, ascii_key),
        String.jaro_distance(query_key, name_key)
      )

    bonus =
      (if String.starts_with?(ascii_key, query_key) or String.starts_with?(name_key, query_key),
        do: 0.15,
        else: 0.0
      ) + pop_bonus(city.population)

    {sim + bonus, city}
  end

  defp pop_bonus(nil), do: 0.0
  defp pop_bonus(pop) when pop <= 0, do: 0.0
  defp pop_bonus(pop), do: :math.log10(pop) / 50.0

  # Prefer “more important” feature codes when names collide
  defp feature_rank("PPLC"), do: 6
  defp feature_rank("PPLA"), do: 5
  defp feature_rank("PPLA2"), do: 4
  defp feature_rank("PPLA3"), do: 3
  defp feature_rank("PPLA4"), do: 2
  defp feature_rank("PPL"), do: 1
  defp feature_rank(_), do: 0

  defp fetch_shortlist(query_key, min_pop) do
    Store.lookup(query_key, min_pop)
  end
end

