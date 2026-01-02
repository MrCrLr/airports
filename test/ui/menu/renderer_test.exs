defmodule Airports.UI.Menu.RendererTest do
  use ExUnit.Case, async: true

  alias Airports.UI.Menu.{Renderer, State}

  defp iolist_to_bin(iodata), do: IO.iodata_to_binary(iodata)

  test "frame shows arrow for selected item" do
    items = ["a", "b", "c"]
    state = %State{idx: 1, start: 0, page_size: 3, n: 3}

    out = items |> Renderer.frame(state) |> iolist_to_bin()

    assert out =~ "   a"
    assert out =~ "-> b"
    assert out =~ "   c"
  end

  test "footer shows correct from-to and index" do
    items = Enum.to_list(1..20)
    state = %State{idx: 5, start: 0, page_size: 6, n: 20}

    out = items |> Renderer.frame(state) |> iolist_to_bin()
    assert out =~ "(1-6 of 20)"
    assert out =~ "[6]"
  end

  test "line(nil, _) pads with blank line (stable redraw)" do
    items = ["only"]
    state = %State{idx: 0, start: 0, page_size: 3, n: 1}

    out = items |> Renderer.frame(state) |> iolist_to_bin()
    # should contain at least 3 row newlines + footer newline
    assert String.split(out, "\r\n") |> length() >= 4
  end

  test "renderer uses tuple label when item is {text, value}" do
    items = [{"Hello", :x}]
    state = %State{idx: 0, start: 0, page_size: 1, n: 1}

    out =
      items
      |> Renderer.frame(state)
      |> IO.iodata_to_binary()

    assert out =~ "-> Hello"
  end
end
