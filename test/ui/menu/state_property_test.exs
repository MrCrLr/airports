defmodule Airports.UI.Menu.StatePropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData
  alias Airports.UI.Menu.State

  # Include unknown actions to ensure they are no-ops
  @actions [:up, :down, :page_up, :page_down, :home, :end, :unknown]

  defp action do
    member_of(@actions)
  end

  defp apply_action(state, :unknown), do: State.step(state, :wat)
  defp apply_action(state, a), do: State.step(state, a)

  defp assert_invariants(%State{idx: idx, start: start, n: n, page_size: page_size}) do
    # basic bounds
    assert idx >= 0
    assert start >= 0
    assert page_size > 0
    assert n >= 0

    if n == 0 do
      # your init + step logic clamps to 0s
      assert idx == 0
      assert start == 0
    else
      # idx must point to a valid element
      assert idx < n

      # start must be within scroll range
      max_start = max(n - page_size, 0)
      assert start <= max_start

      # idx must remain visible inside the window [start, start+page_size-1]
      assert idx >= start
      assert idx < start + page_size
    end
  end

  property "invariants hold after any sequence of actions" do
    check all n <- integer(0..300),
              page_size <- integer(1..60),
              actions <- list_of(action(), max_length: 1_000) do
      s0 = State.init(n, page_size)

      sN =
        Enum.reduce(actions, s0, fn a, s ->
          apply_action(s, a)
        end)

      assert_invariants(sN)
    end
  end

  property ":home always results in idx=0,start=0 (even after random actions)" do
    check all n <- integer(0..300),
              page_size <- integer(1..60),
              actions <- list_of(action(), max_length: 500) do
      s0 =
        Enum.reduce(actions, State.init(n, page_size), fn a, s ->
          apply_action(s, a)
        end)

      s1 = State.step(s0, :home)
      assert s1.idx == 0
      assert s1.start == 0
    end
  end

  property ":end places idx at last element (or 0 when empty) and start at max(n-page_size,0)" do
    check all n <- integer(0..300),
              page_size <- integer(1..60),
              actions <- list_of(action(), max_length: 500) do
      s0 =
        Enum.reduce(actions, State.init(n, page_size), fn a, s ->
          apply_action(s, a)
        end)

      s1 = State.step(s0, :end)

      expected_idx = max(n - 1, 0)
      expected_start = max(n - page_size, 0)

      assert s1.idx == expected_idx
      assert s1.start == expected_start
    end
  end

  property "unknown actions are no-ops" do
    check all n <- integer(0..300),
              page_size <- integer(1..60),
              actions <- list_of(action(), max_length: 200) do
      s =
        Enum.reduce(actions, State.init(n, page_size), fn a, s ->
          apply_action(s, a)
        end)

      assert State.step(s, :totally_unknown_action) == s
    end
  end
end

