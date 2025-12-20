defmodule Airports.Station do
  @moduledoc """
  Domain struct representing a single parsed station from 
  the list of all NOAA airport weather station readings.
  """
 
  defstruct [
    :station_id,   # CYYC
    :state,        # AB
    :station_name, # Calgary International Airport
    :latitude,     # 5.11667
    :longitude,    # -114.01667

    :xml_url,      # https://forecast.weather.gov/xml/current_obs/CYYC.xml
    :html_url      # https://forecast.weather.gov/data/obhistory/CYYC.html
  ]
end
