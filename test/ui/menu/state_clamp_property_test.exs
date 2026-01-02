defmodule Airports.UI.Menu.StateClampPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import StreamData
  alias Airports.UI.Menu.State

  @clamp_actions [:up, :down, :page_up, :page_down]

  defp valid_state() do
    bind(integer(0..300), fn n ->
      bind(integer(1..60), fn page_size ->
        if n == 0 do
          constant(%State{idx: 0, start: 0, n: 0, page_size: page_size})
        else
          max_start = max(n - page_size, 0)

          bind(integer(0..max_start), fn start ->
            max_visible = min(start + page_size - 1, n - 1)

            map(integer(start..max_visible), fn idx ->
              %State{idx: idx, start: start, n: n, page_size: page_size}
            end)
          end)
        end
      end)
    end)
  end

  # mirror of your private clamp_start/4
  defp expected_start(new_idx, start, page_size, n) do
    max_start = max(n - page_size, 0)

    cond do
      new_idx < start ->
        new_idx

      new_idx >= start + page_size ->
        min(new_idx - page_size + 1, max_start)

      true ->
        min(start, max_start)
    end
  end

  defp expected_idx(%State{} = s, :up), do: max(s.idx - 1, 0)
  defp expected_idx(%State{} = s, :down), do: min(s.idx + 1, max(s.n - 1, 0))
  defp expected_idx(%State{} = s, :page_up), do: max(s.idx - s.page_size, 0)
  defp expected_idx(%State{} = s, :page_down), do: min(s.idx + s.page_size, max(s.n - 1, 0))

  property "start follows clamp_start exactly for actions that move idx" do
    check all s <- valid_state(),
              action <- member_of(@clamp_actions) do
      s2 = State.step(s, action)

      new_idx = expected_idx(s, action)
      exp_start = expected_start(new_idx, s.start, s.page_size, s.n)

      assert s2.idx == new_idx
      assert s2.start == exp_start
    end
  end

  property "when new idx stays inside the current window, start does not change" do
    check all s <- valid_state(),
              action <- member_of(@clamp_actions) do
      new_idx = expected_idx(s, action)

      # if the new index is still within the old visible window
      if s.n > 0 and new_idx >= s.start and new_idx < s.start + s.page_size do
        s2 = State.step(s, action)
        assert s2.start == s.start
      end
    end
  end
end

