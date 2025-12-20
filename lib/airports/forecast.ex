defmodule Airports.Forecast do
  @moduledoc """
  Domain struct representing a parsed NOAA current observation.
  """

  defstruct [
    # ---- Identity / location ----
    :station_id,          # "PAMR"
    :location,            # "Anchorage, Merrill Field Airport, AK"
    :latitude,            # "61.21667"
    :longitude,           # "-149.85"

    # ---- Time ----
    :observation_time,        # "Last Update on Dec 19 2025, 8:53 pm AKST"
    :observation_time_rfc822, # "Fri, 19 Dec 2025 20:53:00 -0900"

    # ---- Weather conditions ----
    :weather,                 # "Fair"
    :temperature_string,      # "-6.0 F (-21.1 C)"
    :temp_f,                  # "-6.0"
    :temp_c,                  # "-21.1"
    :dewpoint_string,         # "-9.9 F (-23.3 C)"
    :dewpoint_f,
    :dewpoint_c,
    :relative_humidity,       # "83"

    # ---- Wind ----
    :wind_string,             # "East at 3.5 MPH (3 KT)"
    :wind_dir,                # "East"
    :wind_degrees,            # "100"
    :wind_mph,                # "3.5"
    :wind_kt,                 # "3"
    :wind_gust_mph,
    :wind_gust_kt,
    :windchill_string,
    :windchill_f,
    :windchill_c,

    # ---- Pressure ----
    :pressure_string,         # "1013.6 mb"
    :pressure_mb,
    :pressure_in,

    # ---- Visibility ----
    :visibility_mi,            # "8.00"

    # ---- Links / metadata (optional but useful) ----
    :icon_url_name,
    :icon_url_base,
    :two_day_history_url,
    :ob_url,

    # ---- Misc ----
    :credit,
    :credit_url
  ]
end
