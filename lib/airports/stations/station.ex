defmodule Airports.Stations.Station do

  @moduledoc """
  Domain struct representing a single parsed station from 
  the list of all NOAA airport weather station readings.
  """
 
  defstruct [
    :id,           # CYYC
    :state,        # AB
    :name,         # Calgary International Airport
    :latitude,     # 5.11667
    :longitude,    # -114.01667
    :html_url,     # https://forecast.weather.gov/data/obhistory/CYYC.html
    :rss_url,      # https://forecast.weather.gov/xml/current_obs/CYYC.rss
    :xml_url       # https://forecast.weather.gov/xml/current_obs/CYYC.xml
  ]
end
