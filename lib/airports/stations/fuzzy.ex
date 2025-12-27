defmodule Airports.Stations.Fuzzy do
  alias Airports.Stations.Station

  @min_similarity 0.80

  def resolve_anchor(query, stations) do
    query = normalize(query)

    stations
    |> Enum.find(&exact_match?(&1, query))
    |> case do
      %Station{} = station ->
        {:ok, station}

      nil ->
        fuzzy_match(query, stations)
    end
  end

  defp fuzzy_match(query, stations) do
    stations
    |> Enum.map(&best_token_score(&1, query))
    |> Enum.filter(fn {score, _} -> score >= @min_similarity end)
    |> Enum.max_by(&elem(&1, 0), fn -> nil end)
    |> case do
      nil -> {:error, :no_match}
      {_score, station} -> {:ok, station}
    end
  end

  defp exact_match?(%Station{name: name}, query) do
    normalize(name)
    |> String.contains?(query)
  end

  defp best_token_score(%Station{name: name} = station, query) do
    score =
      name
      |> normalize()
      |> String.split(~r/\s+/)
      |> Enum.map(fn token ->
        if String.length(token) < String.length(query) do
          String.jaro_distance(token, query)
        else
          String.jaro_distance(query, token)
        end
      end)
      |> Enum.max(fn -> 0.0 end)

    {score, station}
  end

  defp normalize(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^a-z\s]/, "")
    |> String.trim()
  end
end

