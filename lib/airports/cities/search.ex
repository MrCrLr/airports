defmodule Airports.Cities.Search do
  alias Airports.Text
  alias Airports.Cities.Store

  @default_limit 10

  def search_candidates(query, opts \\ []) do
    min_pop = Keyword.get(opts, :min_population, 500)
    limit   = Keyword.get(opts, :limit, @default_limit)

    query_key = Text.normalize_key(query)

    # 1) Pull a *shortlisted* set from DB/file first (LIKE/prefix/contains)
    # 2) Then fuzzy-rank in Elixir for final top N
    shortlist = fetch_shortlist(query_key, min_pop)

    shortlist
    |> Enum.map(&score(&1, query_key))
    |> Enum.sort_by(fn {score, city} -> {-score, -(city.population || 0)} end)
    |> Enum.take(limit)
    |> Enum.map(fn {_score, city} -> city end)
  end

  defp score(city, query_key) do
    name_key  = Text.normalize_key(city.name)
    ascii_key = Text.normalize_key(city.asciiname)

    sim =
      max(
        String.jaro_distance(query_key, name_key),
        String.jaro_distance(query_key, ascii_key)
      )

    # small bonus for prefix match + population nudge (keeps “big” cities higher)
    bonus =
      (if String.starts_with?(name_key, query_key), do: 0.15, else: 0.0) +
      pop_bonus(city.population)

    {sim + bonus, city}
  end

  defp pop_bonus(nil), do: 0.0
  defp pop_bonus(pop) when pop <= 0, do: 0.0
  defp pop_bonus(pop), do: :math.log10(pop) / 50.0

  # Replace this with your DB query / file scan.
  defp fetch_shortlist(query_key, min_pop) do
    # Must return City structs/maps with fields:
    # :name, :asciiname, :latitude, :longitude, :country, :admin1, :population
    Store.lookup(query_key, min_pop)
  end
end
