defmodule Airports.UI.Menu.StateTest do
  use ExUnit.Case, async: true

  alias Airports.UI.Menu.State

  test "init sets idx and start to 0" do
    s = State.init(10, 5)
    assert s.idx == 0
    assert s.start == 0
    assert s.page_size == 5
    assert s.n == 10
  end

  test "down increments idx until the last item" do
    s = State.init(3, 5)

    s = State.step(s, :down)
    assert s.idx == 1

    s = State.step(s, :down)
    assert s.idx == 2

    s = State.step(s, :down)
    assert s.idx == 2
  end

  test "up decrements idx until 0" do
    s = State.init(3, 5) |> State.step(:down) |> State.step(:down)
    assert s.idx == 2

    s = State.step(s, :up)
    assert s.idx == 1

    s = State.step(s, :up)
    assert s.idx == 0

    s = State.step(s, :up)
    assert s.idx == 0
  end

  test "when list fits in one page, start never moves" do
    s = State.init(4, 10)

    s =
      Enum.reduce(1..50, s, fn _, acc ->
        acc |> State.step(:down) |> State.step(:up)
      end)

    assert s.start == 0
  end

  test "scrolls start when moving down past the bottom of the window" do
    # n=10, page=4, window indices visible:
    # start=0 => [0,1,2,3]
    s = State.init(10, 4)

    s = s |> State.step(:down) |> State.step(:down) |> State.step(:down)
    assert {s.idx, s.start} == {3, 0}

    # moving to idx=4 should push start to 1 to keep idx visible
    s = State.step(s, :down)
    assert {s.idx, s.start} == {4, 1}

    # idx=5 => start=2
    s = State.step(s, :down)
    assert {s.idx, s.start} == {5, 2}
  end

  test "scrolls start when moving up past the top of the window" do
    s = State.init(10, 4)

    # jump down a bunch so start moves
    s = Enum.reduce(1..6, s, fn _, acc -> State.step(acc, :down) end)
    # At idx=6 with page=4 => start should be 3 (visible [3,4,5,6])
    assert {s.idx, s.start} == {6, 3}

    # move up to idx=2 should pull start up to 2
    s = Enum.reduce(1..4, s, fn _, acc -> State.step(acc, :up) end)
    assert {s.idx, s.start} == {2, 2}
  end

  test "page_down advances by page_size and clamps at the end" do
    s = State.init(10, 4)

    s = State.step(s, :page_down)
    assert {s.idx, s.start} == {4, 1} # keep idx visible in window [1..4]

    s = State.step(s, :page_down)
    assert {s.idx, s.start} == {8, 5} # window [5..8]

    s = State.step(s, :page_down)
    assert {s.idx, s.start} == {9, 6} # clamped to last, window [6..9]
  end

  test "page_up goes back by page_size and clamps at 0" do
    s = State.init(10, 4)
    s = State.step(s, :end)
    assert {s.idx, s.start} == {9, 6}

    s = State.step(s, :page_up)
    assert {s.idx, s.start} == {5, 5} # idx visible in [5..8]

    s = State.step(s, :page_up)
    assert {s.idx, s.start} == {1, 1} # idx visible in [1..4]

    s = State.step(s, :page_up)
    assert {s.idx, s.start} == {0, 0}
  end

  test "home goes to top and end goes to bottom with correct start" do
    s = State.init(10, 4)

    s = State.step(s, :end)
    assert {s.idx, s.start} == {9, 6}

    s = State.step(s, :home)
    assert {s.idx, s.start} == {0, 0}
  end

  test "unknown actions do not change state" do
    s = State.init(10, 4)
    assert State.step(s, :wat) == s
  end

  test "n=0 stays stable (idx 0, start 0) for navigation actions" do
    s = State.init(0, 4)

    s =
      Enum.reduce([:down, :up, :page_down, :page_up, :home, :end], s, fn action, acc ->
        State.step(acc, action)
      end)

    assert {s.idx, s.start, s.n} == {0, 0, 0}
  end
end
