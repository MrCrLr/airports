# Airports

A small Elixir CLI that fetches and displays current weather observations for one or more airports using NOAA’s public XML feeds.

This project focuses on:
- clean CLI argument parsing
- explicit domain modeling with structs
- clear separation between fetch, parse, and render layers

## Install / Build

```bash
mix deps.get
mix escript.build
```

This produces an executable named `./airports`.

## Usage

### Help

```bash
./airports --help
# or
./airports -h
```

### Fetch weather by ICAO code (default)

Pass one or more ICAO codes (normalized to uppercase):

```bash
./airports pamr kjfk
```

Multiple codes:

```bash
./airports KJFK KLAX
```

### Stations

#### List all stations

```bash
./airports list
```

#### Search stations by query (interactive selector)

Search by a city/name query, then select a station from the interactive list. After you select, the CLI prints the forecast.

```bash
./airports search Boston
```

With a larger radius (can produce long lists — paging supported):

```bash
./airports search Dallas --radius 1000
```

#### Selector controls (paging)

- **↑ / ↓** move
- **PgUp / PgDn** page up/down (if your terminal sends these)
- **space / b** page down/up (reliable fallback)
- **g / G** top / bottom
- **Enter** select
- **q** cancel

## Architecture (high level)

```
CLI → Fetch (HTTP) → Parse (XML) → Forecast struct → Render
```

- **Fetch**: retrieves raw XML from NOAA  
- **Parser**: converts XML into a domain struct  
- **CLI / Renderer**: renders output for terminal display  

## Notes

- Written as a learning project inspired by *Programming Elixir* (PragProg)
- Uses Erlang’s `:xmerl` for XML parsing
- Currently a work-in-progress and planning to extend (improve UI, SQL database, tables, JSON output, concurrency, etc.)

