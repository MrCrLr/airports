defmodule Airports.Cities.Selector do
  alias Airports.UI.Menu

  def choose([]), do: {:error, :no_city_matches}

  def choose(cities) do
    items = Enum.map(cities, &format/1)
    Menu.select("Select a city:", items)
  end

  defp format(city) do
    label = "#{city.name}, #{city.admin1} #{city.country}#{pop_suffix(city)}"
    {label, city}
  end

  defp pop_suffix(%{population: nil}), do: ""
  defp pop_suffix(%{population: 0}), do: ""
  defp pop_suffix(%{population: pop}) when is_integer(pop), do: " (pop #{pop})"
end
