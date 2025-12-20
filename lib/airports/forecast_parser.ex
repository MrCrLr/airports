defmodule Airports.ForecastParser do
  @moduledoc """
  Parses NOAA current observation XML into a forecast map.
  """

  alias Airports.Forecast

  def parse(xml) when is_binary(xml) do
    {doc, _} = 
      xml
      |> String.to_charlist()
      |> :xmerl_scan.string()
    
    with {:ok, location}   <- location(doc),
         {:ok, station_id} <- station_id(doc),
         {:ok, weather}    <- weather(doc), 
         {:ok, observation_time}   <- obs_time(doc), 
         {:ok, temperature_string} <- temp_str(doc), 
         {:ok, wind_string} <- wind_string(doc) do
      {:ok,
       %Forecast{
         location: location,
         station_id: station_id,
         observation_time: observation_time,    
         weather: weather,
         temperature_string: temperature_string,
         wind_string: wind_string,

         # optional fields
         latitude: opt_text_at(doc, ~c"//latitude/text()"),
         longitude: opt_text_at(doc, ~c"//longitude/text()"),
         dewpoint_string: opt_text_at(doc, ~c"//dewpoint_string/text()"),       
         relative_humidity: opt_text_at(doc, ~c"//relative_humidity/text()"),      
         pressure_string: opt_text_at(doc, ~c"//pressure_string/text()"),
         visibility_mi: opt_text_at(doc, ~c"//visibility_mi/text()")
       }}
    end
  end

  defp text_at(doc, xpath) do
    case :xmerl_xpath.string(xpath, doc) do
      [{:xmlText, _p, _pos, _lang, value, _type}] ->
        {:ok, to_string(value)}

      _ ->
        {:error, {:missing_field, xpath}}
    end
  end

  defp opt_text_at(doc, xpath) do
    case text_at(doc, xpath) do
      {:ok, value} -> value
      {:error, _} -> nil
    end
  end

  defp location(doc), do: text_at(doc, ~c"//location/text()")
  defp station_id(doc), do: text_at(doc, ~c"//station_id/text()")
  defp weather(doc), do: text_at(doc, ~c"//weather/text()")
  defp obs_time(doc), do: text_at(doc, ~c"//observation_time/text()")
  defp temp_str(doc), do: text_at(doc, ~c"//temperature_string/text()")
  defp wind_string(doc), do: text_at(doc, ~c"//wind_string/text()")
end
