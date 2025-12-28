defmodule Airports.Cities.Selector do
  def choose([]), do: {:error, :no_city_matches}

  def choose(cities) do
    IO.puts("Select a city:")

    cities
    |> Enum.with_index(1)
    |> Enum.each(fn {c, i} ->
      pop = if c.population, do: " (pop #{c.population})", else: ""
      IO.puts("  #{i}. #{c.name}, #{c.admin1} #{c.country}#{pop}")
    end)

    prompt = "Enter number (1–#{length(cities)}) or press Enter to cancel: "
    case IO.gets(prompt) |> to_string() |> String.trim() do
      "" ->
        {:error, :cancelled}

      input ->
        with {n, ""} <- Integer.parse(input),
             true <- n >= 1 and n <= length(cities) do
          {:ok, Enum.at(cities, n - 1)}
        else
          _ -> {:error, :invalid_selection}
        end
    end
  end
end

