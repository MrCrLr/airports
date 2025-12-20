# Airports

A small Elixir CLI that fetches and displays current weather observations for one or more airports using NOAA’s public XML feeds.

This project focuses on:
- clean CLI argument parsing
- explicit domain modeling with structs
- clear separation between fetch, parse, and render layers

## Usage

Run the CLI with one or more ICAO airport codes:

```bash
mix run -e 'Airports.CLI.run(["PAMR", "KJFK"])'
```

Example output includes location, observation time, weather, temperature, wind, and visibility.

## Architecture (high level)

```
CLI → Fetch (HTTP) → Parse (XML) → Forecast struct → Render
```

- **Fetch**: Retrieves raw XML from NOAA
- **Parser**: Converts XML into a `%Forecast{}` domain struct
- **CLI / Renderer**: Renders forecasts for terminal output

## Notes

- Written as a learning project inspired by *Programming Elixir* (PragProg)
- Uses Erlang’s `:xmerl` for XML parsing
- Designed to be extended (tables, JSON output, concurrency, escript)

