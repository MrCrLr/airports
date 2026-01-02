import Config

config :airports,
  index_url: "https://preview-forecast.weather.gov/xml/index.xml", 
  noaa_url: "https://preview-forecast.weather.gov/xml/current_obs",
  cities_path: "data/cities_us_ca_pop500.tsv"

config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

import_config "#{config_env()}.exs"
