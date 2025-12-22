defmodule Airports.StationIndexParser do
  @moduledoc """
  Parses the NOAA station index XML into a list of Station structs.
  """
  
  alias Airports.Station

  def parse(xml) when is_binary(xml) do
    {doc, _} =
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string()

    stations =
      doc
      |> then(& :xmerl_xpath.string(~c"//station", &1))
      |> Enum.map(&parse_station/1)
      |> Enum.filter(&match?({:ok, _}, &1))
      |> Enum.map(fn {:ok, station} -> station end)

    {:ok, stations}
  end

  defp parse_station(station_node) do
    with {:ok, id   } <- id(station_node),
         {:ok, name } <- name(station_node),
         {:ok, state} <- state(station_node) do
      {:ok,
       %Station{
         id:        id,
         name:      name,
         state:     state,
         latitude:  opt_float_at(station_node, ~c"./latitude/text()"),
         longitude: opt_float_at(station_node, ~c"./longitude/text()"),
         xml_url:   opt_text_at(station_node, ~c"./xml_url/text()"),
         html_url:  opt_text_at(station_node, ~c"./html_url/text()"),
         rss_url:   opt_text_at(station_node, ~c"./rss_url/text()")
       }}
    end
  end

  #
  # Required field helpers
  #

  defp text_at(node, xpath) do
    case :xmerl_xpath.string(xpath, node) do
      [{:xmlText, _parents, _pos, _lang, value, _type}] ->
        {:ok, to_string(value)}

      _ ->
        {:error, {:missing_field, xpath}}
    end
  end

  defp id(node),    do: text_at(node, ~c"./station_id/text()")
  defp name(node),  do: text_at(node, ~c"./station_name/text()")
  defp state(node), do: text_at(node, ~c"./state/text()")

  #
  # Optional field helpers
  #

  defp opt_text_at(node, xpath) do
    case text_at(node, xpath) do
      {:ok, value} -> value
      {:error, _}  -> nil
    end
  end

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> nil
    end
  end

  defp opt_float_at(node, xpath) do
    with {:ok, value} <- text_at(node, xpath) do
      parse_float(value)
    else
      _ -> nil
    end
  end
end
