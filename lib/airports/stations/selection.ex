defmodule Airports.Stations.Selector do
  alias Airports.Stations.Station

  def choose([]), do: {:error, :no_results}

  def choose([{station, _distance}]), do: {:ok, station}

  def choose(results) do
    render(results)

    case prompt(length(results)) do
      {:ok, index} ->
        {station, _} = Enum.at(results, index)
        {:ok, station}

      :cancelled ->
        {:error, :cancelled}
    end
  end

  defp render(results) do
    IO.puts("\nSelect a station:\n")

    results
    |> Enum.with_index(1)
    |> Enum.each(fn {{station, distance}, i} ->
      IO.puts("  #{i}. #{format(station, distance)}")
    end)
  end

  defp prompt(count) do
    IO.write("\nEnter number (1–#{count}) or press Enter to cancel: ")

    case IO.gets("") do
      nil ->
        :cancelled

      "\n" ->
        :cancelled

      input ->
        input
        |> String.trim()
        |> Integer.parse()
        |> case do
          {n, ""} when n >= 1 and n <= count ->
            {:ok, n - 1}

          _ ->
            IO.puts("Invalid selection.")
            :cancelled
        end
    end
  end

  defp format(%Station{} = station, distance) do
    "#{station.id} - #{station.name} (#{round(distance)} km)"
  end
end
