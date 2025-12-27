defmodule Airports.Stations.Selection do 
  def choose([]), do: {:error, :no_results}
  def choose([single]), do: {:ok, single}

  def choose(results) do
    results
    |> Enum.map(&format/1)
    |> prompt()
  end

  defp format({station, distance}) do
    "#{station.id} - #{station.name} (#{round(distance)} km)"
  end

  defp prompt(options) do
    # scaffold only
    IO.puts("Select a station:")
    Enum.with_index(options, 1)
    |> Enum.each(fn {opt, i} ->
      IO.puts("#{i}. #{opt}")
    end)

    {:ok, options}
  end

end
