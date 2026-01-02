import Config

config :airports,
  cities_path: "test/fixtures/cities_us_ca_pop500.tsv",
  menu: Airports.MenuStub,
  stations_index: Airports.IndexStub,
  http: Airports.HttpStub
