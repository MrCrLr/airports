defmodule Airports.Cities.City do
  @enforce_keys [:geonameid, :name, :asciiname, :name_key, :latitude, :longitude, :country, :population]
  defstruct [
    :geonameid,
    :name,
    :asciiname,
    :name_key,
    :latitude,
    :longitude,
    :country,
    :admin1,
    :admin2,
    :feature_code,
    :population
  ]

  @type t :: %__MODULE__{
          geonameid: integer(),
          name: String.t(),
          asciiname: String.t(),
          name_key: String.t(),
          latitude: float(),
          longitude: float(),
          country: String.t(),
          admin1: String.t() | nil,
          admin2: String.t() | nil,
          feature_code: String.t() | nil,
          population: integer()
        }
end

