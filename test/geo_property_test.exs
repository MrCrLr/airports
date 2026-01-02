defmodule Airports.GeoPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData
  alias Airports.Geo

  # shrink-friendly coordinates (3 decimal places)
  defp latitude, do: integer(-90_000..90_000) |> map(&(&1 / 1000))
  defp longitude, do: integer(-180_000..180_000) |> map(&(&1 / 1000))

  defp coord do
    bind(latitude(), fn lat ->
      map(longitude(), fn lon -> {lat, lon} end)
    end)
  end

  # floating comparisons: Earth distance math will have tiny rounding noise
  defp approx_equal(a, b, eps), do: abs(a - b) <= eps

  property "distance is never negative" do
    check all p1 <- coord(),
              p2 <- coord() do
      d = Geo.distance_km(p1, p2)
      assert is_number(d)
      assert d >= 0.0
    end
  end

  property "distance is symmetric: d(a,b) == d(b,a)" do
    check all p1 <- coord(),
              p2 <- coord() do
      d1 = Geo.distance_km(p1, p2)
      d2 = Geo.distance_km(p2, p1)
      assert approx_equal(d1, d2, 1.0e-9)
    end
  end

  property "distance to self is zero (within tolerance)" do
    check all p <- coord() do
      d = Geo.distance_km(p, p)
      assert d >= 0.0
      assert approx_equal(d, 0.0, 1.0e-9)
    end
  end

  property "distance is bounded by Earth's half-circumference (~pi*R)" do
    # Your earth radius is 6371, so max great-circle distance is pi*R
    max = :math.pi() * 6371

    check all p1 <- coord(),
              p2 <- coord() do
      d = Geo.distance_km(p1, p2)
      assert d <= max + 1.0e-6
    end
  end

  property "triangle inequality holds approximately: d(a,c) <= d(a,b) + d(b,c)" do
    # Floating point + trig means give a small slack.
    slack = 1.0e-6

    check all a <- coord(),
              b <- coord(),
              c <- coord() do
      dab = Geo.distance_km(a, b)
      dbc = Geo.distance_km(b, c)
      dac = Geo.distance_km(a, c)

      assert dac <= dab + dbc + slack
    end
  end
end

